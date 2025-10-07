const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Supabase with SECRET KEY (backend only)
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SECRET_KEY  // Using SECRET key, NOT anon key
);

// JWT Secret for creating tokens
const JWT_SECRET = process.env.JWT_SECRET || 'your-jwt-secret-change-in-production';

// Middleware to verify JWT token
const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  if (!token) {
    return res.status(401).json({ message: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid token' });
  }
};

// ==================== AUTH ROUTES ====================

// Sign up
app.post('/api/auth/signup', async (req, res) => {
  try {
    const { email, password, profile } = req.body;
    
    // Create user in Supabase auth
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
    });
    
    if (authError) {
      return res.status(400).json({ message: authError.message });
    }
    
    // Create profile in database
    const { error: profileError } = await supabase
      .from('profiles')
      .insert({
        user_id: authData.user.id,
        email: email,
        username: profile.username,
        full_name: profile.full_name,
        school: profile.school,
        age: profile.age,
      });
    
    if (profileError) {
      console.error('Profile creation error:', profileError);
    }
    
    // Create JWT token
    const token = jwt.sign(
      { userId: authData.user.id, email: authData.user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    res.status(201).json({
      token,
      user: {
        id: authData.user.id,
        email: authData.user.email,
        ...profile,
      },
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Sign in
app.post('/api/auth/signin', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Sign in with Supabase
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    
    if (authError) {
      return res.status(401).json({ message: authError.message });
    }
    
    // Get user profile
    const { data: profile } = await supabase
      .from('profiles')
      .select('*')
      .eq('user_id', authData.user.id)
      .single();
    
    // Create JWT token
    const token = jwt.sign(
      { userId: authData.user.id, email: authData.user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    res.json({
      token,
      user: {
        id: authData.user.id,
        email: authData.user.email,
        ...profile,
      },
    });
  } catch (error) {
    console.error('Signin error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Sign out
app.post('/api/auth/signout', verifyToken, async (req, res) => {
  try {
    // Optionally invalidate the session in Supabase
    // For JWT, the client just discards the token
    res.json({ message: 'Signed out successfully' });
  } catch (error) {
    console.error('Signout error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get user profile
app.get('/api/auth/profile', verifyToken, async (req, res) => {
  try {
    const { data: profile, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('user_id', req.user.userId)
      .single();
    
    if (error) {
      return res.status(404).json({ message: 'Profile not found' });
    }
    
    res.json(profile);
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Update user profile
app.put('/api/auth/profile', verifyToken, async (req, res) => {
  try {
    const updates = req.body;
    
    const { data, error } = await supabase
      .from('profiles')
      .update(updates)
      .eq('user_id', req.user.userId)
      .select()
      .single();
    
    if (error) {
      return res.status(400).json({ message: error.message });
    }
    
    res.json(data);
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get current user
app.get('/api/auth/user', verifyToken, async (req, res) => {
  try {
    const { data: user, error } = await supabase.auth.admin.getUserById(req.user.userId);
    
    if (error) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Get profile
    const { data: profile } = await supabase
      .from('profiles')
      .select('*')
      .eq('user_id', req.user.userId)
      .single();
    
    res.json({
      id: user.user.id,
      email: user.user.email,
      ...profile,
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// ==================== PLAID ROUTES ====================

// Create Plaid link token
app.post('/api/plaid/create-link-token', verifyToken, async (req, res) => {
  try {
    const axios = require('axios');
    
    const response = await axios.post(
      `https://${process.env.PLAID_ENVIRONMENT}.plaid.com/link/token/create`,
      {
        client_id: process.env.PLAID_CLIENT_ID,
        secret: process.env.PLAID_SECRET,
        client_name: 'Luni App',
        products: ['transactions', 'accounts'],
        country_codes: ['US', 'CA'],
        language: 'en',
        user: {
          client_user_id: req.user.userId,
        },
      }
    );
    
    res.json({ link_token: response.data.link_token });
  } catch (error) {
    console.error('Plaid link token error:', error);
    res.status(500).json({ message: 'Failed to create link token' });
  }
});

// Exchange Plaid public token
app.post('/api/plaid/exchange-public-token', verifyToken, async (req, res) => {
  try {
    const { public_token } = req.body;
    const axios = require('axios');
    
    const response = await axios.post(
      `https://${process.env.PLAID_ENVIRONMENT}.plaid.com/item/public_token/exchange`,
      {
        client_id: process.env.PLAID_CLIENT_ID,
        secret: process.env.PLAID_SECRET,
        public_token,
      }
    );
    
    const access_token = response.data.access_token;
    const item_id = response.data.item_id;
    
    // Store access_token in database (encrypted in production!)
    const { error } = await supabase
      .from('institutions')
      .insert({
        user_id: req.user.userId,
        access_token,
        item_id,
      });
    
    if (error) {
      console.error('Store token error:', error);
    }
    
    res.json({ success: true, item_id });
  } catch (error) {
    console.error('Exchange token error:', error);
    res.status(500).json({ message: 'Failed to exchange token' });
  }
});

// ==================== START SERVER ====================

app.listen(PORT, () => {
  console.log(`Backend server running on port ${PORT}`);
  console.log(`Supabase URL: ${process.env.SUPABASE_URL}`);
  console.log(`Using Supabase SECRET key (not anon key)`);
});


import image_f150ec46ff6adb6f65158683448cff6bf67c5c13 from 'figma:asset/f150ec46ff6adb6f65158683448cff6bf67c5c13.png';
import image_770816ec0c486fcc4894b95a1b38b37d327f89e4 from 'figma:asset/770816ec0c486fcc4894b95a1b38b37d327f89e4.png';
import image_ab1a03f9f90a03620b468a4adde474ade0152ada from 'figma:asset/ab1a03f9f90a03620b468a4adde474ade0152ada.png';
import image_770816ec0c486fcc4894b95a1b38b37d327f89e4 from 'figma:asset/770816ec0c486fcc4894b95a1b38b37d327f89e4.png';
import image_f150ec46ff6adb6f65158683448cff6bf67c5c13 from 'figma:asset/f150ec46ff6adb6f65158683448cff6bf67c5c13.png';
import { Home, DollarSign, Plus, Split, Users } from "lucide-react";
import { ImageWithFallback } from "./components/figma/ImageWithFallback";
import { Button } from "./components/ui/button";
import { Card, CardContent } from "./components/ui/card";

export default function App() {
  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center p-4 w-2/3">
      {/* Phone Frame */}
      <div className="w-[375px] h-[812px] bg-black rounded-[40px] p-[8px] shadow-2xl">
        <div className="w-full h-full bg-gradient-to-b from-[#fdf3c6] via-white/95 to-white rounded-[32px] overflow-hidden flex flex-col">{/* Status Bar */}
          <div className="h-12 flex items-center justify-between px-6 pt-3">
            <span className="text-sm">9:41</span>
            <div className="flex gap-1">
              <div className="w-4 h-2 bg-green-500 rounded-sm"></div>
              <div className="w-6 h-2 bg-gray-300 rounded-sm"></div>
            </div>
          </div>

          {/* Header */}
          <div className="flex items-center justify-between px-6 py-4">
            <div className="flex items-center gap-3">
              <ImageWithFallback
                src={image_f150ec46ff6adb6f65158683448cff6bf67c5c13}
                alt="Profile"
                className="w-10 h-10 rounded-full object-cover"
              />
              <span className="text-lg font-medium">Luni</span>
            </div>
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center">
                <span className="text-xs">🔔</span>
              </div>
              <div className="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center">
                <ImageWithFallback
                  src={image_770816ec0c486fcc4894b95a1b38b37d327f89e4}
                  alt="User"
                  className="w-8 h-8 rounded-full object-cover"
                />
              </div>
            </div>
          </div>

          {/* Content Area */}
          <div className="flex-1 px-6 pb-6 overflow-y-auto scrollbar-hide">
            
            {/* Greeting Section */}
            <div className="mb-4">
              <div className="flex justify-between items-start mb-3">
                <div>
                  <h2 className="text-xl text-[16px]">Good Morning,</h2>
                  <div className="text-xl text-[20px] bg-[rgba(255,243,243,0)]">Rory!</div>
                </div>
                <div className="flex gap-2">
                  <div className="bg-[linear-gradient(145deg,#fffbe8,#fdf0b6,#f8d777)] px-4 py-1.5 rounded-lg min-w-[80px]">
                    <div className="text-gray-800 text-center">12</div>
                    <div className="text-xs text-gray-600 text-center mt-1">Streak</div>
                  </div>
                  <div className="bg-[linear-gradient(145deg,#fffbe8,#fdf0b6,#f8d777)] px-4 py-1.5 rounded-lg min-w-[100px]">
                    <div className="text-gray-800 text-center">800</div>
                    <div className="text-xs text-gray-600 text-center mt-1">LoonScore</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Daily Report Button */}
            <Button className="w-full mb-3 bg-white text-black hover:bg-gray-50 border-0">
              View Daily Report
            </Button>

            {/* Current Budget Overview */}
            <Card className="mb-[16px] rounded-xl border-0">
              <CardContent className="bg-gray-50 rounded-xl border-0" style={{paddingTop: '16px', paddingLeft: '16px', paddingRight: '16px', paddingBottom: '16px'}}>
                <h3 className="mb-3">Current Budget Overview</h3>
                <div className="flex gap-3 mb-4">
                  <div className="bg-green-50 px-2 py-2 rounded-lg flex-1">
                    <div className="flex items-center gap-1 text-green-700">
                      <span>$80</span>
                      <span className="text-xs">Saved</span>
                    </div>
                    <div className="text-green-700 text-xs">On Track!</div>
                  </div>
                  <div className="bg-green-50 px-2 py-2 rounded-lg flex-1">
                    <div className="flex items-center gap-1 text-green-700">
                      <span>$340</span>
                      <span className="text-xs">Spent</span>
                    </div>
                    <div className="text-green-700 text-xs mb-2">of 500</div>
                    <div className="w-full bg-green-200 rounded-full h-2">
                      <div className="bg-green-600 h-2 rounded-full" style={{ width: '68%' }}></div>
                    </div>
                  </div>
                </div>
                
                {/* Remaining in cycle title */}
                <div className="text-[12px] text-gray-600 mb-3 mt-4">Remaining in cycle</div>
                
                {/* Spending Categories */}
                <div className="flex gap-3 overflow-x-auto pb-2 scrollbar-hide">
                  <div className="bg-green-200 p-3 rounded-lg text-center min-w-[90px] flex-shrink-0">
                    <div className="text-green-800">$40</div>
                    <div className="text-xs text-gray-600 mt-1 mb-2">Food</div>
                    <div className="w-full bg-green-100 rounded-full h-1.5">
                      <div className="bg-green-600 h-1.5 rounded-full" style={{ width: '67%' }}></div>
                    </div>
                  </div>
                  <div className="bg-red-200 p-3 rounded-lg text-center min-w-[90px] flex-shrink-0">
                    <div className="text-red-800">$-10</div>
                    <div className="text-xs text-gray-600 mt-1 mb-2">Shopping</div>
                    <div className="w-full bg-red-100 rounded-full h-1.5">
                      <div className="bg-red-600 h-1.5 rounded-full" style={{ width: '110%' }}></div>
                    </div>
                  </div>
                  <div className="bg-green-300 p-3 rounded-lg text-center min-w-[90px] flex-shrink-0">
                    <div className="text-green-800">$50</div>
                    <div className="text-xs text-gray-600 mt-1 mb-2">Fun</div>
                    <div className="w-full bg-green-100 rounded-full h-1.5">
                      <div className="bg-green-600 h-1.5 rounded-full" style={{ width: '83%' }}></div>
                    </div>
                  </div>
                  <div className="bg-green-100 p-3 rounded-lg text-center min-w-[90px] flex-shrink-0">
                    <div className="text-green-700">$25</div>
                    <div className="text-xs text-gray-600 mt-1 mb-2">Transport</div>
                    <div className="w-full bg-green-50 rounded-full h-1.5">
                      <div className="bg-green-500 h-1.5 rounded-full" style={{ width: '42%' }}></div>
                    </div>
                  </div>
                  <div className="bg-green-100 p-3 rounded-lg text-center min-w-[90px] flex-shrink-0">
                    <div className="text-green-700">$15</div>
                    <div className="text-xs text-gray-600 mt-1 mb-2">Gas</div>
                    <div className="w-full bg-green-50 rounded-full h-1.5">
                      <div className="bg-green-500 h-1.5 rounded-full" style={{ width: '30%' }}></div>
                    </div>
                  </div>
                  <div className="bg-green-500 p-3 rounded-lg text-center min-w-[90px] flex-shrink-0">
                    <div className="text-green-900">$120</div>
                    <div className="text-xs text-gray-600 mt-1 mb-2">Bills</div>
                    <div className="w-full bg-green-200 rounded-full h-1.5">
                      <div className="bg-green-700 h-1.5 rounded-full" style={{ width: '96%' }}></div>
                    </div>
                  </div>
                  <div className="bg-green-200 p-3 rounded-lg text-center min-w-[90px] flex-shrink-0">
                    <div className="text-green-800">$30</div>
                    <div className="text-xs text-gray-600 mt-1 mb-2">Health</div>
                    <div className="w-full bg-green-100 rounded-full h-1.5">
                      <div className="bg-green-600 h-1.5 rounded-full" style={{ width: '50%' }}></div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Current Wallet & Accounts */}
            <Card className="mb-4 rounded-xl border-0">
              <CardContent className="p-4 bg-gray-50 rounded-xl border-0">
                {/* Current Wallet Section */}
                <div className="bg-[linear-gradient(145deg,#fffbe8,#fdf0b6,#f8d777)] p-4 rounded-xl mb-4">
                  <div className="text-sm text-gray-500 mb-1">Current Wallet</div>
                  <div className="text-lg">$3,200</div>
                </div>
                
                {/* Account Bubbles */}
                <div className="flex gap-3 overflow-x-auto pb-2 scrollbar-hide">
                  <div className="bg-blue-100 p-3 rounded-lg text-center min-w-[90px] flex-shrink-0">
                    <div className="text-blue-800">1,252</div>
                    <div className="text-xs text-gray-600 mt-1">Checking</div>
                  </div>
                  <div className="bg-red-100 p-3 rounded-lg text-center min-w-[90px] flex-shrink-0">
                    <div className="text-red-800">-782</div>
                    <div className="text-xs text-gray-600 mt-1">Credit</div>
                  </div>
                  <div className="bg-green-100 p-3 rounded-lg text-center min-w-[90px] flex-shrink-0">
                    <div className="text-green-800">2,700</div>
                    <div className="text-xs text-gray-600 mt-1">Savings</div>
                  </div>
                  <div className="bg-purple-100 p-3 rounded-lg text-center min-w-[90px] flex-shrink-0">
                    <div className="text-purple-800">125</div>
                    <div className="text-xs text-gray-600 mt-1">Investment</div>
                  </div>
                  <div className="bg-orange-100 p-3 rounded-lg text-center min-w-[90px] flex-shrink-0">
                    <div className="text-orange-800">450</div>
                    <div className="text-xs text-gray-600 mt-1">Emergency</div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Bottom Navigation */}
          <div className="px-6 py-4">
            <div className="flex justify-between items-center">
              <div className="flex flex-col items-center gap-1">
                <Home className="w-6 h-6 text-[#eab308]" />
                <span className="text-xs text-[#eab308]">Home</span>
              </div>
              <div className="flex flex-col items-center gap-1">
                <DollarSign className="w-6 h-6 text-gray-400" />
                <span className="text-xs text-gray-400">Track</span>
              </div>
              <div className="w-12 h-12 bg-[linear-gradient(145deg,#f5e68a,#eab308,#d69e2e)] rounded-full flex items-center justify-center">
                <Plus className="w-6 h-6 text-white" />
              </div>
              <div className="flex flex-col items-center gap-1">
                <Split className="w-6 h-6 text-gray-400" />
                <span className="text-xs text-gray-400">Split</span>
              </div>
              <div className="flex flex-col items-center gap-1">
                <Users className="w-6 h-6 text-gray-400" />
                <span className="text-xs text-gray-400">Social</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
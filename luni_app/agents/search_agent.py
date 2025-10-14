import { webSearchTool, hostedMcpTool, Agent, RunContext, AgentInputItem, Runner } from "@openai/agents";


// Tool definitions
const webSearchPreview = webSearchTool({
  searchContextSize: "medium",
  userLocation: {
    type: "approximate"
  }
})
const mcp = hostedMcpTool({
  serverLabel: "zapier",
  allowedTools: [
    "webhooks_by_zapier_get"
  ],
  authorization: "REDACTED",
  requireApproval: "always",
  serverUrl: "https://mcp.zapier.com/api/mcp/mcp"
})
const apiMaster = new Agent({
  name: "API MASTER",
  instructions: "You are a helpful assistant. Your job is to search the web for an open and free-to-use API to get the data the user wants. You will then create short, concise documentation on how the API works and how to call it correctly.",
  model: "gpt-5",
  tools: [
    webSearchPreview
  ],
  modelSettings: {
    reasoning: {
      effort: "low",
      summary: "auto"
    },
    store: true
  }
});

interface AgentContext {
  inputOutputText: string;
}
const agentInstructions = (runContext: RunContext<AgentContext>, _agent: Agent<AgentContext>) => {
  const { inputOutputText } = runContext.context;
  return `Your job is to use the below documented API to return an answer to the user's question. ${inputOutputText}`
}
const agent = new Agent({
  name: "Agent",
  instructions: agentInstructions,
  model: "gpt-5",
  tools: [
    mcp
  ],
  modelSettings: {
    reasoning: {
      effort: "low",
      summary: "auto"
    },
    store: true
  }
});

type WorkflowInput = { input_as_text: string };


// Main code entrypoint
export const runWorkflow = async (workflow: WorkflowInput) => {
  const state = {

  };
  const conversationHistory: AgentInputItem[] = [
    {
      role: "user",
      content: [
        {
          type: "input_text",
          text: workflow.input_as_text
        }
      ]
    }
  ];
  const runner = new Runner({
    traceMetadata: {
      __trace_source__: "agent-builder",
      workflow_id: "wf_68e99d94b1588190a662ff80629dca3b028744904957fc06"
    }
  });
  const apiMasterResultTemp = await runner.run(
    apiMaster,
    [
      ...conversationHistory
    ]
  );
  conversationHistory.push(...apiMasterResultTemp.newItems.map((item) => item.rawItem));

  if (!apiMasterResultTemp.finalOutput) {
      throw new Error("Agent result is undefined");
  }

  const apiMasterResult = {
    output_text: apiMasterResultTemp.finalOutput ?? ""
  };
  const agentResultTemp = await runner.run(
    agent,
    [
      ...conversationHistory
    ],
    {
      context: {
        inputOutputText: apiMasterResult.output_text
      }
    }
  );
  conversationHistory.push(...agentResultTemp.newItems.map((item) => item.rawItem));

  if (!agentResultTemp.finalOutput) {
      throw new Error("Agent result is undefined");
  }

  const agentResult = {
    output_text: agentResultTemp.finalOutput ?? ""
  };
}

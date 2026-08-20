import '../agent_models.dart';

const builtInAgents = [
  AgentDefinition(
    id: 'general',
    name: 'General Assistant',
    description: 'Default helpful assistant',
    isBuiltIn: true,
  ),
  AgentDefinition(
    id: 'coder',
    name: 'Coder',
    description: 'Focused on writing and reviewing code',
    systemPrompt: 'You are an expert software engineer. Be precise and concise.',
    colorValue: 0xFF4CAF50,
    isBuiltIn: true,
  ),
  AgentDefinition(
    id: 'researcher',
    name: 'Researcher',
    description: 'Deep research, cites sources',
    systemPrompt: 'You are a meticulous researcher who always verifies facts.',
    colorValue: 0xFF9C27B0,
    isBuiltIn: true,
  ),
];

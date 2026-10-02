export type LensFunc = { name: string; type: string; effects: string[] }

export type LensModule = {
  file: string
  module: string
  types: string[]
  funcs: LensFunc[]
  passed: boolean
  errors: string[]
  ms: number
}

declare module 'claude-code' {
  interface PluginState {
    'ailang-lens': { modules: LensModule[] }
  }
}

interface ImportMetaEnv {
    readonly VITE_SIGNALR_URL: string
    readonly VITE_QUERY_ID: string
    readonly VITE_PORT?: string
  }
  
  interface ImportMeta {
    readonly env: ImportMetaEnv
  }
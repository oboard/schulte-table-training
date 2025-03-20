export interface Database {
  public: {
    Tables: {
      schulte_records: {
        Row: {
          id: string
          user_id: string
          grid_size: number
          completion_time: number
          created_at: string
        }
        Insert: {
          id?: string
          user_id?: string
          grid_size: number
          completion_time: number
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          grid_size?: number
          completion_time?: number
          created_at?: string
        }
      }
    }
  }
} 
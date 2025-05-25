terraform {
  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = ">= 1.0.0"
    }
  }
}

provider "vercel" {
  api_token = var.vercel_token
}

variable "vercel_token" {
  description = "VercelのAPIトークン"
  type        = string
}

variable "openrouter_api_key" {
  description = "OpenRouterのAPIキー"
  type        = string
  sensitive   = true
}

variable "next_public_supabase_url" {
  description = "SupabaseのURL"
  type        = string
}

variable "next_public_supabase_anon_key" {
  description = "SupabaseのANON_KEY"
  type        = string
}

variable "next_public_ollama_url" {
  description = "OllamaのURL"
  type        = string
}

variable "email_whitelist" {
  description = "メールアドレスのホワイトリスト"
  type        = string
}

variable "next_public_user_file_size_limit" {
  description = "ユーザーファイルサイズ制限"
  type        = number
}

resource "vercel_project" "chatbot_ui" {
  name = "chatbot-ui"
  framework = "nextjs"
  git_repository = {
    type = "github"
    repo = "johnknash2025/chatbot-ui" # ←ご自身のリポジトリに修正
  }
  environment = [
    {
      key    = "OPENROUTER_API_KEY"
      value  = var.openrouter_api_key
      target = ["production", "preview", "development"]
    },
    {
      key    = "NEXT_PUBLIC_SUPABASE_URL"
      value  = var.next_public_supabase_url
      target = ["production", "preview", "development"]
    },
    {
      key    = "NEXT_PUBLIC_SUPABASE_ANON_KEY"
      value  = var.next_public_supabase_anon_key
      target = ["production", "preview", "development"]
    },
    {
      key    = "NEXT_PUBLIC_OLLAMA_URL"
      value  = var.next_public_ollama_url
      target = ["production", "preview", "development"]
    },
    {
      key    = "EMAIL_WHITELIST"
      value  = var.email_whitelist
      target = ["production", "preview", "development"]
    },
    {
      key    = "NEXT_PUBLIC_USER_FILE_SIZE_LIMIT"
      value  = tostring(var.next_public_user_file_size_limit)
      target = ["production", "preview", "development"]
    }
    # 必要に応じて他の環境変数も追加
  ]
}

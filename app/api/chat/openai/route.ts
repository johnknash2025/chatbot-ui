import { checkApiKey, getServerProfile } from "@/lib/server/server-chat-helpers"
import { ChatSettings } from "@/types"
import { OpenAIStream, StreamingTextResponse } from "ai"
import { ServerRuntime } from "next"
import OpenAI from "openai"
import { ChatCompletionCreateParamsBase } from "openai/resources/chat/completions.mjs"
import { CHAT_SETTING_LIMITS } from "@/lib/chat-setting-limits"

export const runtime: ServerRuntime = "edge"

export async function POST(request: Request) {
  const json = await request.json()
  const { chatSettings, messages } = json as {
    chatSettings: ChatSettings
    messages: any[]
  }

  try {
    const profile = await getServerProfile()

    checkApiKey(profile.openai_api_key, "OpenAI")

    const openai = new OpenAI({
      apiKey: profile.openai_api_key || "",
      organization: profile.openai_organization_id
    })

    const maxTokens =
      CHAT_SETTING_LIMITS[chatSettings.model]?.MAX_TOKEN_OUTPUT_LENGTH || 4096

    const isO3Mini = chatSettings.model === "o3-mini-2025-01-31"
    const requestParams = {
      model: chatSettings.model as ChatCompletionCreateParamsBase["model"],
      messages: messages as ChatCompletionCreateParamsBase["messages"],
      stream: true,
      ...(isO3Mini
        ? { max_completion_tokens: maxTokens }
        : { max_tokens: maxTokens, temperature: chatSettings.temperature })
    }

    const response = await openai.chat.completions.create(requestParams)

    // 型エラー回避のため as any を付与
    const stream = OpenAIStream(response as any)

    return new StreamingTextResponse(stream)
  } catch (error: any) {
    let errorMessage = error.message || "An unexpected error occurred"
    const errorCode = error.status || 500

    if (errorMessage.toLowerCase().includes("api key not found")) {
      errorMessage =
        "OpenAI API Key not found. Please set it in your profile settings."
    } else if (errorMessage.toLowerCase().includes("incorrect api key")) {
      errorMessage =
        "OpenAI API Key is incorrect. Please fix it in your profile settings."
    }

    return new Response(JSON.stringify({ message: errorMessage }), {
      status: errorCode
    })
  }
}

from __future__ import annotations

"""Utility functions for working with OpenAI's Codex models."""

from typing import List, Dict, Any

from openai import OpenAI
import tiktoken

# Initialize a single OpenAI client instance
client = OpenAI()


def codex_long_chat(messages: List[Dict[str, Any]]) -> str:
    """Send messages to a Codex chat model, auto-continuing if truncated.

    The Codex models have a maximum context length. This helper automatically
    resubmits "Continue" prompts until the response is complete.

    Parameters
    ----------
    messages:
        A list of message dictionaries in OpenAI chat format. This list will be
        mutated in-place with the assistant responses so that subsequent
        continuations preserve full context.

    Returns
    -------
    str
        The final response content from the assistant.
    """

    model = "codex-1"
    encoder = tiktoken.encoding_for_model(model)

    while True:
        # Calculate remaining tokens so that completion stays within context.
        prompt_tokens = sum(len(encoder.encode(m["content"])) for m in messages)
        max_out = int(192_000 * 0.85) - prompt_tokens

        resp = client.chat.completions.create(
            model=model,
            messages=messages,
            max_completion_tokens=max_out,
            stream=False,
            temperature=0.1,
        )

        # Append assistant response to the conversation history.
        assistant_msg = resp.choices[0].message
        messages.append(assistant_msg)

        # Stop requesting continuations once the model finishes naturally.
        if resp.choices[0].finish_reason != "max_tokens":
            break

        messages.append({"role": "user", "content": "Continue."})

    return assistant_msg.content

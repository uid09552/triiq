# AI trainer

The chat, **Train now** and the AI-written session texts use the LLM you pick
in **Settings → LLM provider**: Claude (your Anthropic key), Ollama Cloud, or
a model you run yourself with Ollama.

## How it works

The trainer is a tool-calling agent that runs **inside the app**. It reads
your **local** data through tools — activities, daily metrics, planned
sessions, the training plan, readiness and the fatigue warning, performance
curves, the fitness forecast, race predictions, bricks — and only the results
of those tools are sent to the model, as part of the conversation. There is
no TriIQ server in between.

## What it can and cannot do

- It **explains** your training from your own numbers and names gaps in the
  data.
- It **proposes**: sessions in Train now, changes to the load curve or a
  session, plan adjustments. Every proposal is a card **you** apply or
  dismiss — it never changes your plan or calendar by itself.
- It **remembers** standing preferences you ask it to ("no hard sessions on
  Fridays"). They are listed under **More → Trainer memory**, tagged when the
  trainer saved them, and you can delete any of them.
- It **consults your own material**: Markdown or text documents imported
  under **More → Knowledge library**, quoted with the document's name and
  treated as information, never as instructions.

## Choosing a model

Tool use needs a capable model. Larger models follow the tool and format
instructions more reliably; with a small local model, expect simpler
answers. With Ollama the context window is raised to 16k tokens so that tool
results fit.

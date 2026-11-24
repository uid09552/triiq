# AI trainer

The chat, **Train now**, the AI-written session texts and the weekly-review
sentence use the models you list in **Settings → AI trainer → Models**:
Claude (your Anthropic key), Ollama Cloud, a model you run yourself with
Ollama, or any OpenAI-compatible server (OpenAI, OpenRouter, LM Studio,
vLLM, llama.cpp…) — one, or several in the order you prefer.

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

## Use with care

The trainer is an AI model plus rules, not a coach or a doctor. Its
answers, proposals and plans can be wrong, and **nothing it says is
guaranteed to be correct or safe**. In particular:

- **Overtraining and health.** Readiness, the fatigue warning and form (CTL −
  ATL) are rough signals from your own data, not diagnoses. Lasting fatigue,
  poor sleep, a rising resting heart rate, falling mood or performance, pain,
  illness or injury are reasons to rest and to talk to a doctor or coach —
  whatever the app suggests.
- **Your own instructions.** Standing preferences in **Trainer memory** and
  the custom instructions in Train now steer the trainer, and a preference
  can make training harder than is wise. The trainer is told to flag a clash
  with safety or your data, but it can miss one; you stay responsible for the
  load you take on.
- **Check before you apply.** Every proposal is a card you apply or dismiss —
  read it against how you feel first.

## Several models and failover

The list is a priority order. Every request goes to the first enabled model;
if it cannot be reached, times out, is rate-limited or overloaded, or turns
out misconfigured (key refused, model unknown, no tool support), the same
request goes to the next one — at the start of a reply or between two tool
steps. That is safe because the trainer's tools only read your data or make
proposals you apply yourself. Text the failed model had started is dropped,
not repeated; a note in the reply says "Switched to … — …: reason", and a
small chip under each reply names the model that answered.

It does **not** switch for things another model would answer the same way:
a content-policy refusal, a conversation longer than the context window, or
a request you cancelled. A model that failed twice in a row is paused for
5 minutes so you don't wait for a dead server each message; **Test** in
Settings (or a success) clears that. Each row shows OK / needs attention /
paused, the reason and when it last answered. If every model fails, one
message lists each model and why.

## Choosing a model

Tool use needs a capable model. Larger models follow the tool and format
instructions more reliably; with a small local model, expect simpler
answers. With Ollama the context window is raised to 16k tokens so that tool
results fit.

**Recommended for training results:** the **gpt-oss 120B** model
(`gpt-oss:120b`) from [ollama.com](https://ollama.com/library/gpt-oss) works
well for generating training results — session plans, explanations and weekly
reviews — and handles the tool calls reliably. Add it as an **Ollama Cloud**
model (`https://ollama.com` plus your Ollama API key, then **Load models**),
or run it yourself on an Ollama server if your hardware is big enough.

## Your own knowledge base

You can give the trainer your own training material, for example swim sets,
taper notes, a coach's guidelines or articles you trust:

1. Open **More → Knowledge library** (Android and Windows).
2. Import Markdown or plain-text documents with the file picker. Level-1 `#`
   headings split a document into searchable sections.
3. Ask the trainer as usual. It searches your documents and quotes the one it
   used by name.

Documents are stored only on your device, count as information and never as
instructions, and are included in the backup. They are sent to the model only
as the matching excerpts the trainer looks up. You can disable or delete a
document at any time.

# avspeech (AVSpeechSynthesizer for Odin)

This package provides a wrapper for Apple's **AVSpeechSynthesizer** framework for Odin, enabling robust text-to-speech functionality on macOS.

## Build and Import

After cloning/downloading the repository, make sure you put the avspeech directory where the Odin compiler can find it, e.g. *shared*, under your main program's directory, etc. Then, in your program, import this directory, e.g. *shared:avspeech*. During building, the necessary framework (AVFoundation) should be linked automagically when you run:

```
odin build .
```

in the root directory of your program.

##  Basic Usage

The library operates on two core concepts: the **Synthesizer** (the speaker) and the **Utterance** (the text/configuration).

### 1. Initialize the Synthesizer

Ccreate the synthesizer instance. Destroy it when you are done.

```
synth := avspeech.make_synthesizer()
defer avspeech.destroy_synthesizer(synth)
```

### 2. The `say` procedure

Use the `say` procedure, which handles utterance creation and destruction internally. You can also manually manage these (see later).

```
// Simple speech using default voice and rate (0.5)
avspeech.say(synth, "Hello from Odin!")

// Speak with custom rate and volume, interrupting any current speech
avspeech.say(synth, "I speak fast!", rate=0.8, volume=0.9, interrupt=true)

// Wait for all queued speech to finish
avspeech.wait_until_done(synth)
```

## Advanced Control (Utterance & Voice)

For more detailed control over rate, pitch, and voice selection, you create and configure an `Utterance` object.

### Utterance Configuration

```
// 1. Get a specific voice (e.g., for UK English)
voice := avspeech.make_voice_with_language("en-GB")
if voice == nil {
// Fallback or error handling
}

// 2. Configure the Utterance
config := avspeech.Utterance_Config{
text:                 "Custom voice, custom pitch\!",
voice:                voice,
rate:                 0.4,
pitch_multiplier:     1.5, // Higher pitch
volume:               0.75,
pre_utterance_delay:  0.5, // 500ms pause before speaking
post_utterance_delay: 0.2,
}

// 3. Create, Speak, and Destroy
utterance := avspeech.make_utterance_from_config(config)
defer avspeech.destroy_utterance(utterance)

avspeech.speak(synth, utterance)
avspeech.wait_until_done(synth)

// Remember to destroy the voice you explicitly retained
avspeech.destroy_voice(voice)
```

In addition, there are functions that directly modify an utterance, e.g. *get/set_rate*, in which case you can create an utterance from a string, via the *make_utterance_from_string* procedure and change the config properties above via separate function calls.

### Voice Retrieval

Use these functions to discover and select available voices on the system:

| Procedure | Description |
| :--- | :--- |
| `avspeech.get_all_voices()` | Returns a slice of all available `Voice` objects. |
| `avspeech.make_voice_with_language(lang: string)` | Returns a retained `Voice` matching the language code (e.g., `"en-US"`). **Requires `avspeech.destroy_voice` call.** |
| `avspeech.make_voice_with_identifier(id: string)` | Returns a retained `Voice` matching a specific identifier. **Requires `avspeech.destroy_voice` call.** |
| `avspeech.get_voice_name(voice)` | Returns the display name (e.g., "Kate"). |
| `avspeech.get_voice_language(voice)` | Returns the BCP-47 language code (e.g., "en-GB"). |
| `avspeech.get_available_languages()` | Returns a slice of unique language codes installed on the system. |

## Control & Status

| Procedure | Description |
| :--- | :--- |
| `avspeech.stop(synth, boundary)` | Immediately stops speech (or waits until the next word boundary). |
| `avspeech.pause(synth, boundary)` | Pauses speech. |
| `avspeech.continue_speaking(synth)` | Resumes paused speech. |
| `avspeech.is_speaking(synth)` | Returns `true` if the synthesizer is currently speaking. |
| `avspeech.is_paused(synth)` | Returns `true` if the synthesizer is currently paused. |
| `avspeech.has_queued_speech(synth)` | Returns `true` if there are utterances waiting to be spoken. |
| `avspeech.wait_until_done(synth)` | Blocks the current execution until the synthesizer finishes speaking all queued utterances. |

## Memory Management

Objects created with `make_` calls require manual destruction to avoid leaks, as they are explicitly retained:

* `avspeech.make_synthesizer()` **→** `avspeech.destroy_synthesizer()`
* `avspeech.make_utterance(...)` **→** `avspeech.destroy_utterance()`
* `avspeech.make_voice_with_language(...)` **→** `avspeech.destroy_voice()`
* `avspeech.make_voice_with_identifier(...)` **→** `avspeech.destroy_voice()`

While the synthesizer and voice objects are usually kept in memory to be reused, the utterance is a single-use configuration object, thus each spoken text should have a new utterance created for it, then destroyed afterwards.

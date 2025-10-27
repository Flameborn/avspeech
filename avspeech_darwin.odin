package avspeech

import "core:c"
import NS "core:sys/darwin/Foundation"
import "base:intrinsics"

foreign import "system:AVFoundation.framework"

Synthesizer :: ^NS.Object
Utterance :: ^NS.Object
Voice :: ^NS.Object

Voice_Quality :: enum c.int {
	Default  = 1,
	Enhanced = 2,
}

Voice_Gender :: enum c.int {
	Unspecified = 0,
	Male        = 1,
	Female      = 2,
}

Speech_Boundary :: enum c.int {
	Immediate = 0,
	Word      = 1,
}

Utterance_Config :: struct {
	text:                 string,
	voice:                Voice,
	rate:                 f32,
	pitch_multiplier:     f32,
	volume:               f32,
	pre_utterance_delay:  f64,
	post_utterance_delay: f64,
}

MINIMUM_SPEECH_RATE :: 0.0
MAXIMUM_SPEECH_RATE :: 1.0
DEFAULT_SPEECH_RATE :: 0.5

@(private)
msg_send :: intrinsics.objc_send

@(private)
ns_string_make :: proc(text: string) -> ^NS.String {
	str := NS.String.alloc()
	return msg_send(^NS.String, str, "initWithUTF8String:", cstring(raw_data(text)))
}

@(private)
ns_string_to_odin :: proc(ns_str: ^NS.String) -> string {
	if ns_str == nil do return ""
	cstr := msg_send(cstring, ns_str, "UTF8String")
	if cstr == nil do return ""
	return string(cstr)
}

@(private)
retain :: proc(obj: ^NS.Object) -> ^NS.Object {
	return msg_send(^NS.Object, obj, "retain")
}

@(private)
release :: proc(obj: ^NS.Object) {
	if obj != nil do msg_send(nil, obj, "release")
}

make_synthesizer :: proc() -> Synthesizer {
	class := cast(^NS.Object)intrinsics.objc_find_class("AVSpeechSynthesizer")
	synth := msg_send(Synthesizer, class, "alloc")
	return msg_send(Synthesizer, synth, "init")
}

destroy_synthesizer :: proc(synth: Synthesizer) {
	release(cast(^NS.Object)synth)
}

speak :: proc(synth: Synthesizer, utterance: Utterance) {
	msg_send(nil, synth, "speakUtterance:", utterance)
}

stop :: proc(synth: Synthesizer, boundary := Speech_Boundary.Immediate) -> bool {
	return msg_send(bool, synth, "stopSpeakingAtBoundary:", boundary)
}

pause :: proc(synth: Synthesizer, boundary := Speech_Boundary.Immediate) -> bool {
	return msg_send(bool, synth, "pauseSpeakingAtBoundary:", boundary)
}

continue_speaking :: proc(synth: Synthesizer) -> bool {
	return msg_send(bool, synth, "continueSpeaking")
}

is_speaking :: proc(synth: Synthesizer) -> bool {
	return msg_send(bool, synth, "isSpeaking")
}

is_paused :: proc(synth: Synthesizer) -> bool {
	return msg_send(bool, synth, "isPaused")
}

has_queued_speech :: proc(synth: Synthesizer) -> bool {
	queue := msg_send(^NS.Array, synth, "speechQueue")
	if queue == nil do return false
	count := msg_send(NS.UInteger, queue, "count")
	return count > 0
}

make_utterance :: proc {
	make_utterance_from_string,
	make_utterance_from_config,
}

make_utterance_from_string :: proc(text: string) -> Utterance {
	ns_text := ns_string_make(text)
	defer release(cast(^NS.Object)ns_text)
	
	class := cast(^NS.Object)intrinsics.objc_find_class("AVSpeechUtterance")
	utt := msg_send(Utterance, class, "alloc")
	return msg_send(Utterance, utt, "initWithString:", ns_text)
}

make_utterance_from_config :: proc(config: Utterance_Config) -> Utterance {
	utt := make_utterance_from_string(config.text)
	
	if config.voice != nil {
		msg_send(nil, utt, "setVoice:", config.voice)
	}
	
	msg_send(nil, utt, "setRate:", config.rate)
	msg_send(nil, utt, "setPitchMultiplier:", config.pitch_multiplier)
	msg_send(nil, utt, "setVolume:", config.volume)
	msg_send(nil, utt, "setPreUtteranceDelay:", config.pre_utterance_delay)
	msg_send(nil, utt, "setPostUtteranceDelay:", config.post_utterance_delay)
	
	return utt
}

destroy_utterance :: proc(utterance: Utterance) {
	release(cast(^NS.Object)utterance)
}

set_voice :: proc(utterance: Utterance, voice: Voice) {
	msg_send(nil, utterance, "setVoice:", voice)
}

set_rate :: proc(utterance: Utterance, rate: f32) {
	msg_send(nil, utterance, "setRate:", rate)
}

set_pitch :: proc(utterance: Utterance, pitch: f32) {
	msg_send(nil, utterance, "setPitchMultiplier:", pitch)
}

set_volume :: proc(utterance: Utterance, volume: f32) {
	msg_send(nil, utterance, "setVolume:", volume)
}

set_pre_delay :: proc(utterance: Utterance, delay: f64) {
	msg_send(nil, utterance, "setPreUtteranceDelay:", delay)
}

set_post_delay :: proc(utterance: Utterance, delay: f64) {
	msg_send(nil, utterance, "setPostUtteranceDelay:", delay)
}

get_rate :: proc(utterance: Utterance) -> f32 {
	return msg_send(f32, utterance, "rate")
}

get_pitch :: proc(utterance: Utterance) -> f32 {
	return msg_send(f32, utterance, "pitchMultiplier")
}

get_volume :: proc(utterance: Utterance) -> f32 {
	return msg_send(f32, utterance, "volume")
}

make_voice_with_language :: proc(language: string) -> Voice {
	class := cast(^NS.Object)intrinsics.objc_find_class("AVSpeechSynthesisVoice")
	ns_lang := ns_string_make(language)
	defer release(cast(^NS.Object)ns_lang)
	
	voice := msg_send(Voice, class, "voiceWithLanguage:", ns_lang)
	if voice != nil {
		retain(cast(^NS.Object)voice)
	}
	return voice
}

make_voice_with_identifier :: proc(identifier: string) -> Voice {
	class := cast(^NS.Object)intrinsics.objc_find_class("AVSpeechSynthesisVoice")
	ns_id := ns_string_make(identifier)
	defer release(cast(^NS.Object)ns_id)
	
	voice := msg_send(Voice, class, "voiceWithIdentifier:", ns_id)
	if voice != nil {
		retain(cast(^NS.Object)voice)
	}
	return voice
}

destroy_voice :: proc(voice: Voice) {
	release(cast(^NS.Object)voice)
}

get_all_voices :: proc(allocator := context.allocator) -> []Voice {
	class := cast(^NS.Object)intrinsics.objc_find_class("AVSpeechSynthesisVoice")
	array := msg_send(^NS.Array, class, "speechVoices")
	if array == nil do return nil
	
	count := msg_send(NS.UInteger, array, "count")
	voices := make([]Voice, count, allocator)
	
	for i in 0..<count {
		voices[i] = msg_send(Voice, array, "objectAtIndex:", i)
	}
	
	return voices
}

get_voice_language :: proc(voice: Voice) -> string {
	ns_str := msg_send(^NS.String, voice, "language")
	return ns_string_to_odin(ns_str)
}

get_voice_identifier :: proc(voice: Voice) -> string {
	ns_str := msg_send(^NS.String, voice, "identifier")
	return ns_string_to_odin(ns_str)
}

get_voice_name :: proc(voice: Voice) -> string {
	ns_str := msg_send(^NS.String, voice, "name")
	return ns_string_to_odin(ns_str)
}

get_voice_quality :: proc(voice: Voice) -> Voice_Quality {
	return msg_send(Voice_Quality, voice, "quality")
}

get_voice_gender :: proc(voice: Voice) -> Voice_Gender {
	return msg_send(Voice_Gender, voice, "gender")
}

get_current_language :: proc() -> string {
	class := cast(^NS.Object)intrinsics.objc_find_class("AVSpeechSynthesisVoice")
	ns_str := msg_send(^NS.String, class, "currentLanguageCode")
	return ns_string_to_odin(ns_str)
}

get_available_languages :: proc(allocator := context.allocator) -> []string {
	voices := get_all_voices(allocator)
	if voices == nil do return nil
	defer delete(voices)
	
	languages := make([dynamic]string, allocator)
	seen := make(map[string]bool, allocator)
	defer delete(seen)
	
	for voice in voices {
		lang := get_voice_language(voice)
		if lang not_in seen {
			append(&languages, lang)
			seen[lang] = true
		}
	}
	
	return languages[:]
}

process_run_loop :: proc(duration := 0.01) {
	run_loop_class := cast(^NS.Object)intrinsics.objc_find_class("NSRunLoop")
	run_loop := msg_send(^NS.Object, run_loop_class, "currentRunLoop")
	
	date_class := cast(^NS.Object)intrinsics.objc_find_class("NSDate")
	date := msg_send(^NS.Object, date_class, "dateWithTimeIntervalSinceNow:", duration)
	
	msg_send(nil, run_loop, "runUntilDate:", date)
}

say :: proc(
	synth: Synthesizer,
	text: string,
	voice: Voice = nil,
	rate := f32(DEFAULT_SPEECH_RATE),
	pitch := f32(1.0),
	volume := f32(1.0),
	interrupt := false,
) {
	if interrupt && is_speaking(synth) {
		stop(synth)
	}
	
	utterance := make_utterance(text)
	defer destroy_utterance(utterance)
	
	if voice != nil {
		set_voice(utterance, voice)
	}
	
	set_rate(utterance, rate)
	set_pitch(utterance, pitch)
	set_volume(utterance, volume)
	
	speak(synth, utterance)
	process_run_loop(0.001)
}

wait_until_done :: proc(synth: Synthesizer, poll_interval := 0.1) {
	for is_speaking(synth) || has_queued_speech(synth) {
		process_run_loop(poll_interval)
	}
}
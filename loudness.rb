#!/usr/bin/env ruby

require 'open3'
require 'json'

ffmpeg_bin = '/usr/local/bin/ffmpeg'
target_il  = ARGV[2] # target loudness in LUFS (e.g -23)
target_lra = ARGV[3] # target loudness range measured in Loudness units (LU) eg. +11
target_tp  = ARGV[4] # target truepeak loudness of the true peak eg -2
samplerate = ARGV[5] # samplerate of output e.g. '48k'

if ARGF.argv.count != 6
  puts "Usage: #{$PROGRAM_NAME} input.wav output.wav targetIL-eg-24 targetLRA-eg+11 targetTP-eg-2 samplerate-eg'48k'"
  exit 1
end

ff_string  = "#{ffmpeg_bin} -hide_banner "
ff_string += "-i #{ARGF.argv[0]} "
ff_string += '-af loudnorm='
ff_string += 'dual_mono=true:'
ff_string += "I=#{target_il}:"
ff_string += "LRA=#{target_lra}:"
ff_string += "tp=#{target_tp}:"
ff_string += 'print_format=json '
ff_string += '-f null -'

_stdin, _stdout, stderr, wait_thr = Open3.popen3(ff_string)

if wait_thr.value.success?
  stats = JSON.parse(stderr.read.lines[-12, 12].join)
  loudnorm_string  = '-af loudnorm='
  loudnorm_string += 'dual_mono=true:'
  loudnorm_string += 'print_format=summary:'
  loudnorm_string += 'linear=true:'
  loudnorm_string += "I=#{target_il}:"
  loudnorm_string += "LRA=#{target_lra}:"
  loudnorm_string += "tp=#{target_tp}:"
  loudnorm_string += "measured_I=#{stats['input_i']}:"
  loudnorm_string += "measured_LRA=#{stats['input_lra']}:"
  loudnorm_string += "measured_tp=#{stats['input_tp']}:"
  loudnorm_string += "measured_thresh=#{stats['input_thresh']}:"
  loudnorm_string += "offset=#{stats['target_offset']}"
else
  puts stderr.read
  exit 1
end

ff_string  = "#{ffmpeg_bin} -y -hide_banner "
ff_string += "-i #{ARGF.argv[0]} "
ff_string += "#{loudnorm_string} "
ff_string += "-ar #{samplerate} "
ff_string += ARGF.argv[1].to_s

_stdin, _stdout, stderr, wait_thr = Open3.popen3(ff_string)

if wait_thr.value.success?
  puts stderr.read.lines[-12, 12].join
  exit 0
else
  puts stderr.read
  exit 1
end

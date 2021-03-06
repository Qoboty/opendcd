#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright 2014 Paul R. Dixon
# \file

set -x
#First we fetch the small pre-built models then and the online neural networks
#models
LIBRISPEECH=http://www.kaldi-asr.org/downloads/build/6/trunk/egs/librispeech/s5
LANG=lang_test_tgsmall
mkdir -p $LANG/
mkdir -p $LANG/phones
mkdir -p nnet_a
REQUIRED="phones/disambig.int L_disambig.fst G.fst words.txt"
for F in $REQUIRED; do
  D=dirname $F
  B=basename $F
  if [ ! -f $LANG/$F ]; then
    wget -P $LANG/$D/  $LIBRISPEECH/$DATA/$LANG/$F
  fi
done

REQUIRED="tree final.mdl"
for F in $REQUIRED; do
  if [ ! -f nnet_a/$F ]; then
    wget $LIBRISPEECH/exp/nnet2_online/nnet_a/$F -P nnet_a/
  fi
done
#We also need the models for the iVector extractor
IVECTOR=http://www.kaldi-asr.org/downloads/build/6/trunk/egs/librispeech/s5/exp/nnet2_online/nnet_a_online/ivector_extractor
REQUIRED="final.dubm final.ie final.mat global_cmvn.stats online_cmvn.conf splice_opts"
for F in $REQUIRED; do
  if [ ! -f ivector_extractor/$F ]; then
    wget -P ivector_extractor/ $IVECTOR/$F
  fi
done

#Fetch some test data and make s short test
if [ ! -f test-clean.tar.gz ]; then
  wget http://www.openslr.org/resources/12/test-clean.tar.gz
  tar -zxf test-clean.tar.gz
fi

./makescp.py "LibriSpeech/test-clean/1089/134686/" > test-clean.scp
cut -f 1 -d' ' test-clean.scp  > names.txt
paste names.txt names.txt > test-clean.utt2psk

if [ ! -f dev-clean.tar.gz ]; then
  wget http://www.openslr.org/resources/12/dev-clean.tar.gz
  tar -zxf dev-clean.tar.gz
  curl http://www.kaldi-asr.org/downloads/build/6/trunk/egs/librispeech/s5/data/dev_clean/archive.tar.gz  -o dev_clean_lists.tar.gz
  curl http://www.kaldi-asr.org/downloads/build/6/trunk/egs/librispeech/s5/exp/nnet2_online/nnet_a_online/decode_dev_clean_tgsmall/scoring/test_filt.txt \
    -o LibriSpeech/dev_clean//test_filt.txt
fi

#Build the medium sized graph
#wget http://www.kaldi-asr.org/downloads/build/6/trunk/egs/librispeech/s5/data/lang_test_tgmed/archive.tar.gz
#mkdir graph_test_tgmed
#tar -zxvf archive.tar.gz -C graph_test_tgmed --strip-components=1
#../script/makeclevel.sh lang_test_tgmed  nnet_a graph_test_tgmed ../../kaldi
#http://www.openslr.org/resources/11/4-gram.arpa.gz
#http://www.openslr.org/resources/11/3-gram.arpa.gz

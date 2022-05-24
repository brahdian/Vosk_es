#!/bin/bash

. path.sh

set -x
mfccdir=/mfcc/

rm -rf data/*.lm.gz data/lang_local data/lang data/lang_test data/lang_test_rescore
rm -rf exp/chain/lgraph
rm -rf exp/chain/graph

utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt
steps/make_mfcc.sh --nj 2000 --cmd run.pl data/train exp/make_mfcc/train $mfccdir
steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train $mfccdir
utils/validate_data_dir.sh data/train
utils/fix_data_dir.sh data/train

mkdir -p data/dict
cp db/phone/* data/dict
./dict.py > data/dict/lexicon.txt

ngram-count -wbdiscount -order 4 -text db/extra.txt -lm data/extra.lm.gz
ngram -order 4 -lm db/fr.lm.gz -mix-lm data/extra.lm.gz -lambda 0.95 -write-lm data/fr-mix.lm.gz
ngram -order 4 -lm data/fr-mix.lm.gz -prune 3e-8 -write-lm data/fr-mixp.lm.gz
ngram -lm data/fr-mixp.lm.gz -write-lm data/fr-mix-small.lm.gz

utils/prepare_lang.sh data/dict "[unk]" data/lang_local data/lang
utils/format_lm.sh data/lang data/fr-mix-small.lm.gz data/dict/lexicon.txt data/lang_test
utils/mkgraph_lookahead.sh --self-loop-scale 1.0 data/lang_test exp/chain/tdnn exp/chain/tdnn/graph
utils/build_const_arpa_lm.sh data/fr-mix.lm.gz data/lang_test data/lang_test_rescore

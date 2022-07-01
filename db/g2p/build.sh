#!/bin/sh

. /home/ubuntu/vosk/kaldi/tools/env.sh
export PATH=/home/ubuntu/.local/lib/python3.10/site-packages/phonetisaurus/bin/x86_64:$PATH
export LD_LIBRARY_PATH=/home/ubuntu/.local/lib/python3.10/site-packages/phonetisaurus/lib/x86_64


./convert.py es.dic 20
echo "align"
phonetisaurus-align --input=es.dic.train --ofile=es.dic.corpus
echo "ngram"
# ngram-count -order 8 –kn-modify-counts-at-end -ukndiscount -text es.dic.corpus -lm es.dic.arpa
ngram-count -order 8 –kn-modify-counts-at-end -text es.dic.corpus -lm es.dic.arpa
echo "count stop"
phonetisaurus-arpa2wfst --lm=es.dic.arpa -ofile=es.fst
phonetisaurus-apply --model=es.fst --word_list es.dic.test.list > es.dic.hyp
./eval.py es.dic.test es.dic.hyp

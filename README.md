### Don't use this -- use `raco pkg` instead!

git clone http://github.com/samth/raco-git.git
raco link raco-git
raco setup raco-git

Then:
raco git --github offby1 rudybot
racket -t rudybot/loop

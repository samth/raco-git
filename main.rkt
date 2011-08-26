#lang racket

(require setup/link setup/setup-unit setup/option-unit setup/option-sig
         launcher/launcher-sig launcher/launcher-unit dynext/dynext-sig
         dynext/dynext-unit compiler/sig compiler/option-unit compiler/compiler-unit)

(define (mk-gh-url s1 s2) (format "http://github.com/~a/~a.git" s1 s2))

(define (clone u)
  (unless (system (string-append "git clone " u))
    (raise-user-error "git clone failed")))

(define-values/invoke-unit/infer setup:option@)

(define (run-setup s)
  (make-planet #f)
  (make-user #t) ;; must be on for linked collections to work
  (make-info-domain #f)
  (make-docs #f)
  (parallel-workers 2)
  (specific-collections (list (list s)))
  (invoke-unit
   (compound-unit/infer
    (import setup-option^)
    (export)
    (link launcher@ dynext:compile@ dynext:link@ dynext:file@
          compiler:option@ compiler@ setup@))
   (import setup-option^)))

(define git-url (make-parameter #f))
(define collect-name (make-parameter #f))
(define dir-name (make-parameter #f))
(define root? (make-parameter #f))

(define (main)
  (command-line
   #:program "raco git"
   #:once-any
   [("--github") user repo "github user and repo"
                 (git-url (mk-gh-url user repo))
                 (collect-name repo)
                 (dir-name repo)]
   [("--url") url "git url" (git-url url)]
   #:once-each
   [("--collect") coll "name of collection" (collect-name coll) (dir-name coll)]
   [("--dir") dir "name of directory" (dir-name dir)]
   [("--root") "this repository contains multiple collections" (root? #t)])
  (unless (and (git-url) (dir-name) (collect-name))
    (error 'fail "not enough arguments"))
  (clone (git-url))
  (links (dir-name) #:name (collect-name) #:root? (root?))
  (run-setup (collect-name)))
(main)


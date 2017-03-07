;; sql-style-guide
;; implementing http://www.sqlstyle.guide/ as an Emacs mode

;; Copyright (C) 2017 David Morrisroe

;; Keywords: languages sql style
;; https://github.com/davem8/sql-style-guide

;; This file is not part of GNU Emacs.


;; This is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc.., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;; Notes

;; This mode is still under construction I'm borrowing heavily from
;; sql-indent by Alex Schroeder et al.
;; https://github.com/bsvingen/sql-indent

;; The idea is to create mode which indents SQL
;; the way I like to code which is based on sqlstyle.guide
;; which I think is based on Joe Celko's book

;; most of the time for SELECT quires I want to right align
;; key words to col 8 and start all field names on col 10
;; with the , on line 8

;;  SELECT
;;         account_id
;;       , customer_name
;;       , birth_dt
;;    FROM account  AS acc
;;    JOIN customer AS customer
;;   WHERE birth_dt
;; BETWEEN DATE '1980-01-01'
;;     AND DATE '1989-12-31'

;; For now I'll use the same SQL Mode in Emacs which takes
;; care of key word colouring.

;; I would like to automatically UPCASE key words
;; and maybe downcase field names.
;; I think I'm going to run into lots of edge cases
;; I haven't thought about yet.

(defcustom sql-indent-first-column-regexp-8
  (concat "\\(^\\s-*" (regexp-opt '(
				    "order"
				    "group"
				    "truncate"
				    "distinct"
				    ) t) "\\(\\b\\|\\s-\\)\\)\\|\\(^```$\\)")
    "Regexp matching keywords relevant for indentation.
Of key words of different lengths
The regexp matches lines which start SQL statements of differing length key word
and it matches lines that should be indented to be right aligned on col 8.
The regexp is created at compile-time.  Take a look at the
source before changing it."

  :type 'regexp
  :group 'SQL)

(defcustom sql-indent-first-column-regexp-7
  (concat "\\(^\\s-*" (regexp-opt '(
				    "qualify"
				    "between"
				    ) t) "\\(\\b\\|\\s-\\)\\)\\|\\(^```$\\)")
    "Regexp matching keywords relevant for indentation.
Of key words of different lengths
The regexp matches lines which start SQL statements of differing length key word
and it matches lines that should be indented to be right aligned on col 8.
The regexp is created at compile-time.  Take a look at the
source before changing it."

  :type 'regexp
  :group 'SQL)

(defcustom sql-indent-first-column-regexp-6
  (concat "\\(^\\s-*" (regexp-opt '(
				    "select" "update" "insert" "delete"
				    "having"
				    "create"
				    ) t) "\\(\\b\\|\\s-\\)\\)\\|\\(^```$\\)")
  "Regexp matching keywords relevant for indentation.
Of key words of different lengths
The regexp matches lines which start SQL statements of differing length key word
and it matches lines that should be indented to be right aligned on col 8.
The regexp is created at compile-time.  Take a look at the
source before changing it."
  :type 'regexp
  :group 'SQL)



(defcustom sql-indent-first-column-regexp-5

  (concat "\\(^\\s-*" (regexp-opt '(

				    "union"
				    "where"
				    "group"
				    
				    ) t) "\\(\\b\\|\\s-\\)\\)\\|\\(^```$\\)")
    "Regexp matching keywords relevant for indentation.
Of key words of different lengths
The regexp matches lines which start SQL statements of differing length key word
and it matches lines that should be indented to be right alighned on col 8.
The regexp is created at compile-time.  Take a look at the
source before changing it."

  :type 'regexp
  :group 'SQL)


(defcustom sql-indent-first-column-regexp-4
  (concat "\\(^\\s-*" (regexp-opt '("from"
				    "into"
				    "join"
				    "left"
				    "drop"
				    "case"
				    "when"
				    "else") t) "\\(\\b\\|\\s-\\)\\)\\|\\(^```$\\)")
  "Regexp matching keywords relevant for indentation.
Of key words of different lengths
The regexp matches lines which start SQL statements of differing length key word
and it matches lines that should be indented to be right alighned on col 8.
The regexp is created at compile-time.  Take a look at the
source before changing it."

  :type 'regexp
  :group 'SQL)


(defcustom sql-indent-first-column-regexp-3
  (concat "\\(^\\s-*" (regexp-opt '("end") t) "\\(\\b\\|\\s-\\)\\)\\|\\(^```$\\)")
  "Regexp matching keywords relevant for indentation.
Of key words of different lengths
The regexp matches lines which start SQL statements of differing length key word
and it matches lines that should be indented to be right alighned on col 8.
The regexp is created at compile-time.  Take a look at the
source before changing it."

  :type 'regexp
  :group 'SQL)


(defcustom sql-indent-first-column-regexp-2
  (concat "\\(^\\s-*" (regexp-opt '("as"
				    "on") t) "\\(\\b\\|\\s-\\)\\)\\|\\(^```$\\)")
  "Regexp matching keywords relevant for indentation.
Of key words of different lengths
The regexp matches lines which start SQL statements of differing length key word
and it matches lines that should be indented to be right alighned on col 8.
The regexp is created at compile-time.  Take a look at the
source before changing it."

  :type 'regexp
  :group 'SQL)

;; this comma one is because I like to place all column names
;; indented with the comma on col 8 and a space the the field name
(defcustom sql-indent-first-column-regexp-comma
  (concat "\\(^\\s-*" (regexp-opt '(",") t) "\\(\\b\\|\\s-\\)\\)\\|\\(^```$\\)")
  "Regexp matching keywords relevant for indentation.
Of key words of different lengths
The regexp matches lines which start SQL statements of differing length key word
and it matches lines that should be indented to be right alighned on col 8.
The regexp is created at compile-time.  Take a look at the
source before changing it."

  :type 'regexp
  :group 'SQL)


(defun how-far ()
  "Return the number of spaces to indent a key word so all the 
words are right aligned at col 8"
  (interactive)
  (save-excursion
    (beginning-of-line)
    (cond ((looking-at sql-indent-first-column-regexp-8) 0)
	  ((looking-at sql-indent-first-column-regexp-7) 1)
	  ((looking-at sql-indent-first-column-regexp-6) 2)
	  ((looking-at sql-indent-first-column-regexp-5) 3)
	  ((looking-at sql-indent-first-column-regexp-4) 4)
	  ((looking-at sql-indent-first-column-regexp-3) 5)
	  ((looking-at sql-indent-first-column-regexp-2) 6)
	  ((looking-at sql-indent-first-column-regexp-comma) 7)
	  ;; default to 0 no indent
	  (t 0))))


(defun thf ()
  ;; test-how-far display the value returned by how-far
  (interactive)
  (message
   (number-to-string
    (how-far))))
	 
    
(defun right-indent ()
  (interactive)
  (beginning-of-line)
  (indent-line-to (how-far)))


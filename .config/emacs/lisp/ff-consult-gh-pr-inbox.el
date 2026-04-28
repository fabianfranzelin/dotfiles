;;; ff-consult-gh-pr-inbox.el --- Inbox filter for PRs to be acted on  -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides an inbox for PRs that require action from the user.
;; It extends the consult-gh package
;;
;; Usage:
;;   M-x consult-gh-pr-inbox
;;
;; To filter by specific user/repo:
;;   (setq consult-gh-pr-inbox-user "fabian-franzelin_pace")
;;   (setq consult-gh-pr-inbox-repo "PACE-INT/aos")
;;
;; Or use let-binding:
;;   (let ((consult-gh-pr-inbox-user "fabian-franzelin_pace")
;;         (consult-gh-pr-inbox-repo "PACE-INT/aos"))
;;     (consult-gh-pr-inbox))

;;; Code:

(require 'consult-gh)

(defcustom consult-gh-pr-inbox-user "@me"
  "User to filter PRs for in `consult-gh-pr-inbox'.

Use \"@me\" for the currently authenticated user, or specify a
GitHub username like \"fabian-franzelin_pace\"."
  :group 'consult-gh
  :type 'string)

(defcustom consult-gh-pr-inbox-repo nil
  "Repository to filter PRs for in `consult-gh-pr-inbox'.

When nil, search across all repositories.
When set, should be in \"owner/repo\" format, e.g. \"PACE-INT/aos\"."
  :group 'consult-gh
  :type '(choice (const :tag "All repositories" nil)
                 (string :tag "Repository (owner/repo)")))

(defun consult-gh--pr-inbox-get-host ()
  "Get the GitHub host, initializing auth if needed.
Falls back to `consult-gh-default-host' if auth cannot be determined."
  (or (consult-gh--auth-account-host)
      (progn
        (consult-gh--auth-current-active-account)
        (consult-gh--auth-account-host))
      consult-gh-default-host))

(defun consult-gh--pr-inbox-assigned-builder (input)
  "Find open non-draft PRs assigned to configured user.

Uses `consult-gh-pr-inbox-user' for the assignee filter (default \"@me\").
Uses `consult-gh-pr-inbox-repo' for repository filter (default nil = all repos).

INPUT is passed as extra arguments to \"gh search prs\"."
  (pcase-let* ((user (or consult-gh-pr-inbox-user "@me"))
               (repo consult-gh-pr-inbox-repo)
               (reason (if (string= user "@me")
                           "Assigned to me"
                         (format "Assigned to %s" user)))
               (cmd (append consult-gh-args
                            (list "search" "prs"
                                  "--sort" "updated"
                                  "--assignee" user
                                  "--state" "open"
                                  "--json" "repository,title,number,labels,updatedAt,state,url,commentsCount"
                                  "--template" (concat "{{range .}}"
                                                       "true" "      "
                                                       "{{.repository.nameWithOwner}}" "      "
                                                       "{{.title}}" "      "
                                                       "{{.number}}" "      "
                                                       "{{.state}}" "      "
                                                       "{{.updatedAt}}" "      "
                                                       "{{.labels}}" "      "
                                                       "{{.url}}" "      "
                                                       "{{.commentsCount}}" "      "
                                                       reason
                                                       "\n" "{{end}}"))
                            (when repo (list "--repo" repo))))
               (`(,arg . ,opts) (consult-gh--split-command input))
               (flags (append cmd opts)))
    (unless (or (member "-L" flags) (member "--limit" flags))
      (setq opts (append opts (list "--limit" (format "%s" consult-gh-pr-maxnum)))))
    (cons (append cmd opts (remove nil (list arg)) (list "--" "-is:draft" (format "-reviewed-by:%s" user))) nil)))

(defvar consult-gh--pr-inbox-assigned-source
  (list :name "Assigned to me (non-draft)"
        :narrow ?a
        :async (consult--process-collection #'consult-gh--pr-inbox-assigned-builder
                 :transform (consult--async-transform #'consult-gh--search-dashboard-transform)
                 :min-input 0)
        :async-wrap (lambda (sink) (lambda (action)
                                     (if (stringp action)
                                         (funcall sink (propertize action 'consult--force t))
                                       (funcall sink action))))
        :group #'consult-gh--dashboard-group
        :state #'consult-gh--dashboard-state
        :require-match t
        :category 'consult-gh-prs
        :preview-key consult-gh-preview-key
        :sort t)
  "Source for PRs assigned to user (open, non-draft).")

(defun consult-gh--pr-inbox-mentions-builder (input)
  "Find open PRs that mention configured user.

Uses `consult-gh-pr-inbox-user' for the mentions filter (default \"@me\").
Uses `consult-gh-pr-inbox-repo' for repository filter (default nil = all repos).

INPUT is passed as extra arguments to \"gh search prs\"."
  (pcase-let* ((user (or consult-gh-pr-inbox-user "@me"))
               (repo consult-gh-pr-inbox-repo)
               (reason (if (string= user "@me")
                           "Mentions me"
                         (format "Mentions %s" user)))
               (cmd (append consult-gh-args
                            (list "search" "prs"
                                  "--sort" "updated"
                                  "--mentions" user
                                  "--state" "open"
                                  "--json" "repository,title,number,labels,updatedAt,state,url,commentsCount"
                                  "--template" (concat "{{range .}}"
                                                       "true" "      "
                                                       "{{.repository.nameWithOwner}}" "      "
                                                       "{{.title}}" "      "
                                                       "{{.number}}" "      "
                                                       "{{.state}}" "      "
                                                       "{{.updatedAt}}" "      "
                                                       "{{.labels}}" "      "
                                                       "{{.url}}" "      "
                                                       "{{.commentsCount}}" "      "
                                                       reason
                                                       "\n" "{{end}}"))
                            (when repo (list "--repo" repo))))
               (`(,arg . ,opts) (consult-gh--split-command input))
               (flags (append cmd opts)))
    (unless (or (member "-L" flags) (member "--limit" flags))
      (setq opts (append opts (list "--limit" (format "%s" consult-gh-pr-maxnum)))))
    (cons (append cmd opts (remove nil (list arg))) nil)))

(defvar consult-gh--pr-inbox-mentions-source
  (list :name "Mentions me"
        :narrow ?m
        :async (consult--process-collection #'consult-gh--pr-inbox-mentions-builder
                 :transform (consult--async-transform #'consult-gh--search-dashboard-transform)
                 :min-input 0)
        :async-wrap (lambda (sink) (lambda (action)
                                     (if (stringp action)
                                         (funcall sink (propertize action 'consult--force t))
                                       (funcall sink action))))
        :group #'consult-gh--dashboard-group
        :state #'consult-gh--dashboard-state
        :require-match t
        :category 'consult-gh-prs
        :preview-key consult-gh-preview-key
        :sort t)
  "Source for PRs that mention user.")

(defcustom consult-gh-pr-inbox-sources
  (list 'consult-gh--pr-inbox-assigned-source
        'consult-gh--pr-inbox-mentions-source)
  "A list of sources for `consult-gh-pr-inbox'.

Each source in this list is a plist that can be passed to `consult--multi'.
For an example see `consult-gh--pr-inbox-assigned-source'."
  :group 'consult-gh
  :type '(repeat symbol))

(defun consult-gh--pr-inbox (prompt &optional initial)
  "List actionable PRs for configured user.

This is a non-interactive internal function.
For the interactive version see `consult-gh-pr-inbox'.

This searches for PRs that are either:
- Assigned to `consult-gh-pr-inbox-user' (open, non-draft)
- Mentioning `consult-gh-pr-inbox-user' in comments

When `consult-gh-pr-inbox-repo' is set, results are filtered to that repository.

Description of Arguments:

  PROMPT  the prompt in the minibuffer
          \(passed as PROMPT to `consult--read'\)
  INITIAL an optional arg for the initial input in the minibuffer
          \(passed as INITIAL to `consult--read'\)"
  (consult-gh-with-host
   (consult-gh--pr-inbox-get-host)
   (setq prompt "PR Inbox: ")
   (consult--multi consult-gh-pr-inbox-sources
                   :prompt prompt
                   :group #'consult-gh--dashboard-group
                   :history '(:input consult-gh--dashboard-history)
                   :sort nil)))

;;;###autoload
(defun consult-gh-pr-inbox (&optional initial noaction prompt)
  "List actionable PRs for configured user.

Shows two categories of PRs:
- PRs assigned to `consult-gh-pr-inbox-user' that are open and not in draft state
- PRs where someone @mentioned `consult-gh-pr-inbox-user' in a comment

By default, searches for \"@me\" (current authenticated user) across all repos.
Customize with:
  `consult-gh-pr-inbox-user' - GitHub username or \"@me\"
  `consult-gh-pr-inbox-repo' - Repository in \"owner/repo\" format, or nil for all

Example to filter for specific user and repo:
  (setq consult-gh-pr-inbox-user \"fabian-franzelin_pace\")
  (setq consult-gh-pr-inbox-repo \"PACE-INT/aos\")

Upon selection of a candidate either
 - if NOACTION is non-nil  candidate is returned
 - if NOACTION is nil      candidate is passed to `consult-gh-pr-action'

INITIAL is an optional arg for the initial input in the minibuffer.

If PROMPT is non-nil, use it as the query prompt.

Use narrow keys to filter results:
  \\`a' - Show only PRs assigned to me (non-draft)
  \\`m' - Show only PRs that mention me

Additional command line arguments can be passed in the minibuffer input
by typing \"--\" followed by command line arguments.
For example:
  -- -L 50
will set the limit for maximum results to 50."
  (interactive)
  (let* ((prompt (or prompt "PR Inbox: "))
         (sel (consult-gh--pr-inbox prompt initial)))
    ;; Track repos/orgs in history
    (when-let ((reponame (and (stringp (car sel))
                              (get-text-property 0 :repo (car sel)))))
      (add-to-history 'consult-gh--known-repos-list reponame))
    (when-let ((username (and (stringp (car sel))
                              (get-text-property 0 :user (car sel)))))
      (add-to-history 'consult-gh--known-orgs-list username))
    (if noaction
        sel
      (and (stringp (car sel))
           (funcall consult-gh-pr-action (car sel))))))

(provide 'ff-consult-gh-pr-inbox)

;;; ff-consult-gh-pr-inbox.el ends here

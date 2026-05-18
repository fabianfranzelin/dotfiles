((org-mode . ((org-export-with-toc . t)
              (org-export-with-author . t)
              (org-confirm-babel-evaluate . nil)
              (eval . (setq org-publish-project-alist
                            `(("org-project"
                               :base-directory ,(file-name-directory (buffer-file-name))
                               :publishing-directory ,(concat (file-name-directory (buffer-file-name)) "../public/")
                               :publishing-function org-html-publish-to-html)))))))

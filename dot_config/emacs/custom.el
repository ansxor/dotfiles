(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(high-contrast))
 '(custom-safe-themes
   '("aa545934ce1b6fd16b4db2cf6c2ccf126249a66712786dd70f880806a187ac0b" "047ec205dcb5edbb94b35800110150a6e41e6cc92c0ccfb2ed25ac3df94331a6" "d20676cc62ddfb3da01035b525fbf6da26760ff48c08f0a15dc573f4738ecbd7" "f673fcb252373cc618097e29647325c7afa0bc586a34588f8a6603651ba3f789" "48b54c5eb3a9ac1d81ffec4c9f6aaf68511dc0b601b256b62483f390c0219dc7" "05dd3c709da9cdcdeebe212f427866952a2c604688b0213ae6cbc8b306becc22" "982fb05996c9af2359bc50d43f404bec670e9166d7ca40a231f893933a0cef8a" "fe1293faa6f41dff98cb65d1a876b8b94f6de099e26b704d0abde8e11a1b905e" "2b4b734833f7f1b59a4c0040989e9fa1ef8ee9df39ce746da981a7b4933e71bc" "fbf73690320aa26f8daffdd1210ef234ed1b0c59f3d001f342b9c0bbf49f531c" "d41229b2ff1e9929d0ea3b4fde9ed4c1e0775993df9d998a3cdf37f2358d386b" "a75aff58f0d5bbf230e5d1a02169ac2fbf45c930f816f3a21563304d5140d245" "2e7dc2838b7941ab9cabaa3b6793286e5134f583c04bde2fba2f4e20f2617cf7" default))
 '(explicit-shell-file-name "/usr/bin/fish")
 '(inhibit-startup-screen t)
 '(safe-local-variable-values
   '((etags-regen-ignores "test/manual/etags/")
     (etags-regen-regexp-alist
      (("c" "objc")
       "/[ \11]*DEFVAR_[A-Z_ \11(]+\"\\([^\"]+\\)\"/\\1/" "/[ \11]*DEFVAR_[A-Z_ \11(]+\"[^\"]+\",[ \11]\\([A-Za-z0-9_]+\\)/\\1/"))
     (eglot-report-progress nil)))
 '(treemacs-no-png-images t)
 '(treemacs-position 'right))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-document-title ((t (:inherit outline-1 :height 1.6))))
 '(org-level-1 ((t (:inherit outline-1 :height 1.5))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.4))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.2)))))

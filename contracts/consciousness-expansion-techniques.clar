;; Consciousness Expansion Techniques Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))

;; Data Variables
(define-data-var technique-counter uint u0)
(define-map expansion-techniques uint {
    name: (string-ascii 50),
    description: (string-utf8 500),
    creator: principal,
    quantum-inspiration: (string-utf8 200),
    safety-level: uint,
    effectiveness-rating: uint
})

;; Public Functions
(define-public (create-technique (name (string-ascii 50)) (description (string-utf8 500)) (quantum-inspiration (string-utf8 200)) (safety-level uint))
    (let ((technique-id (+ (var-get technique-counter) u1)))
        (asserts! (and (>= safety-level u1) (<= safety-level u10)) err-invalid-parameters)
        (map-set expansion-techniques technique-id {
            name: name,
            description: description,
            creator: tx-sender,
            quantum-inspiration: quantum-inspiration,
            safety-level: safety-level,
            effectiveness-rating: u0
        })
        (var-set technique-counter technique-id)
        (ok technique-id)
    )
)

(define-public (rate-technique (technique-id uint) (rating uint))
    (let ((technique (unwrap! (map-get? expansion-techniques technique-id) err-invalid-parameters)))
        (asserts! (and (>= rating u1) (<= rating u10)) err-invalid-parameters)
        (map-set expansion-techniques technique-id (merge technique {
            effectiveness-rating: (/ (+ (get effectiveness-rating technique) rating) u2)
        }))
        (ok true)
    )
)

(define-public (update-safety-level (technique-id uint) (new-safety-level uint))
    (let ((technique (unwrap! (map-get? expansion-techniques technique-id) err-invalid-parameters)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (and (>= new-safety-level u1) (<= new-safety-level u10)) err-invalid-parameters)
        (map-set expansion-techniques technique-id (merge technique {
            safety-level: new-safety-level
        }))
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-technique (technique-id uint))
    (map-get? expansion-techniques technique-id)
)

(define-read-only (get-technique-count)
    (var-get technique-counter)
)


;; Safety Protocols Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))

;; Data Variables
(define-data-var protocol-counter uint u0)
(define-map safety-protocols uint {
    name: (string-ascii 50),
    description: (string-utf8 500),
    creator: principal,
    severity-level: uint,
    active: bool
})

;; Public Functions
(define-public (create-protocol (name (string-ascii 50)) (description (string-utf8 500)) (severity-level uint))
    (let ((protocol-id (+ (var-get protocol-counter) u1)))
        (asserts! (and (>= severity-level u1) (<= severity-level u10)) err-invalid-parameters)
        (map-set safety-protocols protocol-id {
            name: name,
            description: description,
            creator: tx-sender,
            severity-level: severity-level,
            active: true
        })
        (var-set protocol-counter protocol-id)
        (ok protocol-id)
    )
)

(define-public (update-protocol-status (protocol-id uint) (new-status bool))
    (let ((protocol (unwrap! (map-get? safety-protocols protocol-id) err-invalid-parameters)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set safety-protocols protocol-id (merge protocol {
            active: new-status
        }))
        (ok true)
    )
)

(define-public (update-severity-level (protocol-id uint) (new-severity-level uint))
    (let ((protocol (unwrap! (map-get? safety-protocols protocol-id) err-invalid-parameters)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (and (>= new-severity-level u1) (<= new-severity-level u10)) err-invalid-parameters)
        (map-set safety-protocols protocol-id (merge protocol {
            severity-level: new-severity-level
        }))
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-protocol (protocol-id uint))
    (map-get? safety-protocols protocol-id)
)

(define-read-only (get-protocol-count)
    (var-get protocol-counter)
)


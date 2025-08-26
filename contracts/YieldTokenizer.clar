;; Yield Tokenizer Contract
;; A protocol that separates yield from principal, allowing trading of future yield streams as separate tokens

;; Define fungible tokens
(define-fungible-token principal-token)
(define-fungible-token yield-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-not-authorized (err u103))
(define-constant err-position-not-found (err u104))

;; Data variables
(define-data-var next-position-id uint u1)
(define-data-var protocol-fee-rate uint u100) ;; 1% = 100 basis points

;; Position tracking
(define-map yield-positions 
    uint 
    {
        owner: principal,
        principal-amount: uint,
        yield-rate: uint, ;; Annual yield rate in basis points (e.g., 500 = 5%)
        maturity-block: uint,
        is-active: bool
    })

;; User position tracking
(define-map user-positions principal (list 50 uint))

;; Function 1: Tokenize Yield - Separates principal and yield into tradeable tokens
(define-public (tokenize-yield (principal-amount uint) (annual-yield-rate uint) (duration-blocks uint))
    (let (
        (position-id (var-get next-position-id))
        (maturity-block (+ stacks-block-height duration-blocks))
        (estimated-yield (/ (* principal-amount annual-yield-rate duration-blocks) (* u365 u144 u10000))) ;; Approximate blocks per year
        (user-positions-list (default-to (list) (map-get? user-positions tx-sender)))
    )
    (begin
        ;; Validate inputs
        (asserts! (> principal-amount u0) err-invalid-amount)
        (asserts! (and (>= annual-yield-rate u100) (<= annual-yield-rate u5000)) err-invalid-amount) ;; Between 1% and 50%
        (asserts! (> duration-blocks u0) err-invalid-amount)
        
        ;; Transfer STX as collateral
        (try! (stx-transfer? principal-amount tx-sender (as-contract tx-sender)))
        
        ;; Mint principal tokens (representing the locked principal)
        (try! (ft-mint? principal-token principal-amount tx-sender))
        
        ;; Mint yield tokens (representing future yield rights)
        (try! (ft-mint? yield-token estimated-yield tx-sender))
        
        ;; Create yield position
        (map-set yield-positions position-id {
            owner: tx-sender,
            principal-amount: principal-amount,
            yield-rate: annual-yield-rate,
            maturity-block: maturity-block,
            is-active: true
        })
        
        ;; Update user positions
        (map-set user-positions tx-sender (unwrap! (as-max-len? (append user-positions-list position-id) u50) err-invalid-amount))
        
        ;; Increment position counter
        (var-set next-position-id (+ position-id u1))
        
        ;; Print event
        (print {
            action: "tokenize-yield",
            position-id: position-id,
            owner: tx-sender,
            principal-amount: principal-amount,
            estimated-yield: estimated-yield,
            maturity-block: maturity-block
        })
        
        (ok position-id)
    )))

;; Function 2: Redeem Yield - Allows yield token holders to claim their yield portion
(define-public (redeem-yield (position-id uint) (yield-token-amount uint))
    (let (
        (position (unwrap! (map-get? yield-positions position-id) err-position-not-found))
        (yield-holder-balance (ft-get-balance yield-token tx-sender))
        (total-yield-for-position (/ (* (get principal-amount position) (get yield-rate position) (- (get maturity-block position) stacks-block-height)) (* u365 u144 u10000)))
        (yield-claim-ratio (/ (* yield-token-amount u10000) total-yield-for-position))
        (stx-yield-claim (/ (* total-yield-for-position yield-claim-ratio) u10000))
        (protocol-fee (/ (* stx-yield-claim (var-get protocol-fee-rate)) u10000))
        (net-yield-claim (- stx-yield-claim protocol-fee))
    )
    (begin
        ;; Validate position exists and is active
        (asserts! (get is-active position) err-position-not-found)
        (asserts! (>= stacks-block-height (get maturity-block position)) err-not-authorized) ;; Only after maturity
        
        ;; Validate yield token ownership
        (asserts! (>= yield-holder-balance yield-token-amount) err-insufficient-balance)
        (asserts! (> yield-token-amount u0) err-invalid-amount)
        
        ;; Burn yield tokens
        (try! (ft-burn? yield-token yield-token-amount tx-sender))
        
        ;; Transfer yield (STX) to yield token holder minus protocol fee
        (try! (as-contract (stx-transfer? net-yield-claim tx-sender tx-sender)))
        
        ;; Transfer protocol fee to contract owner
        (try! (as-contract (stx-transfer? protocol-fee tx-sender contract-owner)))
        
        ;; Print event
        (print {
            action: "redeem-yield",
            position-id: position-id,
            redeemer: tx-sender,
            yield-tokens-burned: yield-token-amount,
            stx-received: net-yield-claim,
            protocol-fee: protocol-fee
        })
        
        (ok net-yield-claim)
    )))

;; Read-only functions
(define-read-only (get-position (position-id uint))
    (map-get? yield-positions position-id))

(define-read-only (get-user-positions (user principal))
    (map-get? user-positions user))

(define-read-only (get-principal-token-balance (user principal))
    (ft-get-balance principal-token user))

(define-read-only (get-yield-token-balance (user principal))
    (ft-get-balance yield-token user))

(define-read-only (get-protocol-fee-rate)
    (var-get protocol-fee-rate))

;; Owner functions
(define-public (set-protocol-fee-rate (new-rate uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (<= new-rate u1000) err-invalid-amount) ;; Max 10%
        (var-set protocol-fee-rate new-rate)
        (ok true)))

;; Transfer functions for token trading
(define-public (transfer-principal-tokens (amount uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) err-not-authorized)
        (try! (ft-transfer? principal-token amount sender recipient))
        (ok true)))

(define-public (transfer-yield-tokens (amount uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) err-not-authorized)
        (try! (ft-transfer? yield-token amount sender recipient))
        (ok true)))
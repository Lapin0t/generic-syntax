\begin{code}
module environment where

open import Data.Nat as ℕ
open import Data.Sum
open import Function

open import indexed
open import var

infix 5 _─Env
\end{code}
%<*env>
\begin{code}
record _─Env (m : ℕ) (𝓥 : ℕ → Set) (n : ℕ) : Set where
  constructor pack; field lookup : Var m → 𝓥 n
\end{code}
%</env>
\begin{code}
open _─Env public

\end{code}
%<*thinning>
\begin{code}
Thinning : ℕ → ℕ → Set
Thinning m n = (m ─Env) Var n
\end{code}
%</thinning>
\begin{code}

ε : ∀ {𝓥 n} → (0 ─Env) 𝓥 n
lookup ε ()

_<$>_ : {𝓥 𝓦 : ℕ → Set} {m n p : ℕ} → (𝓥 n → 𝓦 p) → (m ─Env) 𝓥 n → (m ─Env) 𝓦 p
lookup (f <$> ρ) k = f (lookup ρ k)

split : ∀ m {n} → Var (m ℕ.+ n) → Var m ⊎ Var n
split zero    k     = inj₂ k
split (suc m) z     = inj₁ z
split (suc m) (s k) = map s id $ split m k

_>>_ : ∀ {𝓥 m n p} → (m ─Env) 𝓥 p → (n ─Env) 𝓥 p → (m ℕ.+ n ─Env) 𝓥 p
lookup (ρ₁ >> ρ₂) k = [ lookup ρ₁ , lookup ρ₂ ]′ (split _ k)

infixl 10 _∙_
_∙_ : ∀ {𝓥 m n} → (m ─Env) 𝓥 n → 𝓥 n → (suc m ─Env) 𝓥 n
lookup (ρ ∙ v) z    = v
lookup (ρ ∙ v) (s k) = lookup ρ k

infix 2 _⊆_
_⊆_ : ℕ → ℕ → Set
m ⊆ n = (m ─Env) Var n

refl : ∀ {m} → m ⊆ m
refl = pack id

select : ∀ {m n p 𝓥} → m ⊆ n → (n ─Env) 𝓥 p → (m ─Env) 𝓥 p
lookup (select ren ρ) k = lookup ρ (lookup ren k)

extend : ∀ {n} → n ⊆ suc n
extend = pack s

\end{code}
%<*box>
\begin{code}
□ : (ℕ → Set) → (ℕ → Set)
(□ T) m = [ Thinning m ⟶ T ]
\end{code}
%</box>
\begin{code}

extract : {T : ℕ → Set} → [ □ T ⟶ T ]
extract = _$ refl

join : {T : ℕ → Set} → [ □ (□ T) ⟶ □ T ]
join = extract

duplicate : {T : ℕ → Set} → [ □ T ⟶ □ (□ T) ]
duplicate t ρ σ = t (select ρ σ)

\end{code}
%<*thinnable>
\begin{code}
Thinnable : (ℕ → Set) → Set
Thinnable 𝓥 = [ 𝓥 ⟶ □ 𝓥 ]
\end{code}
%</thinnable>
\begin{code}

th^Var : Thinnable Var
th^Var v ρ = lookup ρ v

th^Env : ∀ {m 𝓥} → Thinnable 𝓥 → Thinnable ((m ─Env) 𝓥)
lookup (th^Env th^𝓥 ρ ren) k = th^𝓥 (lookup ρ k) ren

th^□ : ∀ {T} → Thinnable (□ T)
th^□ = duplicate
\end{code}

%<*kripke>
\begin{code}
Kripke : (𝓥 𝓒 : ℕ → Set) → (ℕ → ℕ → Set)
Kripke 𝓥 𝓒 0 = 𝓒
Kripke 𝓥 𝓒 m = □ ((m ─Env) 𝓥 ⟶ 𝓒)
\end{code}
%</kripke>

\begin{code}
th^Kr : {𝓥 𝓒 : ℕ → Set} (m : ℕ) → Thinnable 𝓒 → Thinnable (Kripke 𝓥 𝓒 m)
th^Kr zero     th^𝓒 = th^𝓒
th^Kr (suc _)  th^𝓒 = th^□
\end{code}

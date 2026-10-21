# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users
A mix of people who run HR for small and mid-sized Kuwaiti businesses that have no HR department. All of these groups are primary users:
- **Business owners** who handle salaries, leave and end-of-service themselves.
- **In-house accountants or admin staff** who keep employee records on the owner's behalf.
- **External accounting offices** that manage HR for several client companies.

The job is the same for all of them: keep employee records, loans, leave balances and end-of-service liabilities correct and compliant with Kuwaiti labor law, without needing HR expertise.

People use it on both phone (installed as a PWA) and desktop. Neither device is secondary, so both experiences have to be excellent.

## Product Purpose
Prime HR replaces error-prone Excel sheets and heavyweight HR suites with a focused tool for Kuwaiti labor-law calculations. Success means the user trusts the numbers it shows (end-of-service, leave balance, outstanding loans) enough to pay out on them, and can find any figure in seconds.

## Positioning
- **Kuwaiti labor-law math built in.** End-of-service follows Law 6/2010 Art. 51 (15 days per year for the first 5 years, 30 days per year after, capped at 18 months) and the Art. 53 resignation tiers (0 / ½ / ⅔ / full at under 3 / 3–5 / 5–10 / 10+ years). Leave accrues 30 working days per year per Art. 70 (as amended): leave days count working days only, with Friday and Saturday as weekly rest days, and first-year leave is due after 6 months of service. The daily rate is monthly salary ÷ 30. Unpaid days beyond the balance are deducted from the monthly salary, not from end-of-service dues. All of it is calculated automatically, and EOS can be based on basic or full salary.
- **Simple and cheap.** 49.000 KWD per year for unlimited employees, with no training needed.
- **Arabic-first.** Built RTL in Arabic, with full English parity.
- **Personal support.** Activation, renewal and support happen directly with Prime over WhatsApp (+965 65068000).

## Operating Context
- Signup, then manual approval by the Prime admin, then a 1-year subscription, then renewal over WhatsApp.
- Main workflows:
  - Add or edit employees (basic + housing + transport + other allowances).
  - Record loans and their deductions.
  - Record paid and unpaid leave.
  - Record EOS payments.
  - End an employee's service, choosing employer termination or resignation, plus a service end date.
- For active employees, EOS is shown side by side as two estimates: employer termination and resignation.
- Data can be exported as a JSON backup or to Excel.
- The admin tab (Prime only) manages subscribers: pending, active and expired.

## Capabilities and Constraints
- Single static `index.html` deployed on Netlify, backed by Supabase (auth, plus the tables `employees`, `loans`, `eos_payments`, `leave_records` and `user_profiles`, plus admin RPCs).
- Currency is KWD with 3 decimal places. Dates are Gregorian.
- Bilingual UI through an `ar`/`en` translation table. The default is `dir="rtl"`.
- Installable as a PWA (add-to-home-screen prompt).
- Undecided, per the roadmap: payroll runs, a WPS file, document-expiry alerts (Civil ID, residency, passport), online payment via MyFatoorah, tiered plans, multi-user roles, and an employee self-service portal.

## Brand Commitments
- Name: **Prime HR** / **نظام برايم للموارد البشرية**, part of Prime (Prime Printing Co., Kuwait).
- Existing logo and app icon are embedded in `index.html`. The brand navy is `#0d2b5e` (PWA theme color).
- Voice: clear, trustworthy and practical Modern Standard Arabic, the same in English. Never legalistic or stiff.

## Evidence on Hand
- Labor-law article references are cited in code comments and UI hints.
- No testimonials, customer counts, logos or case studies exist. Do not fabricate them.

## Product Principles
1. **Numbers are the product.** Every financial figure must be traceable to its legal basis and inputs. Precision (3 dp KWD) and clarity outrank decoration.
2. **No HR degree required.** The UI explains legal concepts in plain language at the point of decision, such as termination type or EOS basis.
3. **Arabic is not a translation.** RTL layout, Arabic typography and Arabic copy are first-class. English must reach parity without breaking the Arabic layout.
4. **Phone and desk are equals.** Every workflow is fully doable on a phone, and dense tables still scan well on desktop.
5. **Human support is a feature.** WhatsApp contact with Prime is part of the experience, not a fallback.

## Accessibility & Inclusion
- Target WCAG 2.1 AA (contrast, keyboard, screen-reader heading order), in both RTL and LTR.
- Many users are non-technical owners, some of them older, so use readable type sizes and generous touch targets on mobile.

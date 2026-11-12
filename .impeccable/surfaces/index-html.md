---
version: 1
slug: "index-html"
primary_target: "index.html"
related_targets: []
---

# Surface: Employee detail drawer (inside the app, index.html)

Mode: Operate. Extension of the established app world (navy/blue tokens, Cairo/Barlow, 12px radius cards). Code-led. No DESIGN.md change.

Audience & job: owner / accountant / accounting office who needs one employee's full financial picture (salary, EOS, leave, loans, payments) without stitching four tabs together, and a document to hand the employee at settlement.

## Direction contract
THESIS: One employee, one number, fully explained. The drawer leads with Net due and lets the user trace it line by line to Art. 51/53 and Art. 70 inputs. Refuses the generic "profile card + tabs of tables" HR record.
OWN-WORLD: Existing app tokens only. Navy lead block (same language as dashboard kpi-lead), white sections with hairline dividers, label/value rows with tabular KWD figures, blue primary actions, red only for end service.
STORY: Who is this → what are they owed now → why (EOS breakdown, leave, loans, payments) → what can I do (quick actions) → hand over a signed statement.
FIRST VIEWPORT: Header (name, no., status, hire date, years) + quick actions + navy Net due block with a scenario switch (employer termination / resignation) for active staff.
SIGNATURE: Scenario switch re-computes the whole breakdown live; print produces a bilingual-aware A4 settlement statement with signature lines.
RISKS: Must reuse computeEmployeeDerived/calcEOSBase (no second math); drawer must not trap users on mobile (full-screen sheet, Escape/back closes).

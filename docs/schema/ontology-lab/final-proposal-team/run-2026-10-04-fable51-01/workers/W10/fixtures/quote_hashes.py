# NFC-WS1 (catalog normalizationVersions): Unicode NFC, whitespace runs -> one U+0020, trimmed; sha256 over UTF-8.
# Computed over the stored `exact` quote text only; snapshot bytes are not hashed (snapshots use SYNTHETIC_FIXTURE).
import hashlib, re, unicodedata, sys
QUOTES = {
 'basis-label-directions': 'Take two (2) capsules every morning with or without food.',
 'basis-label-amount': 'Serving Size: 2 Vegetarian Capsules, Servings: 30, Amount Per Serving: Elysium NR (Nicotinamide Riboside Chloride) 250 mg',
 'basis-label-other': 'Other Ingredients | Microcrystalline Cellulose, Hypromellose, Vegetable Magnesium Stearate and Silica',
 'dellinger-capsule': 'The investigational product NRPT contained 125 mg of NR and 25 mg of pterostilbene per capsule.',
 'dellinger-four-caps': 'All subjects took four capsules daily.',
 'dellinger-primary-objective': 'The primary objective of this study was to evaluate the safety and tolerability of two doses of NRPT in elderly participants during and after eight weeks of treatment.',
 'conze-capsule': 'The NR capsule consisted of 100 mg or 250 mg of NR chloride (99% purity) as the active ingredient and microcrystalline cellulose and vegetarian capsule as non-active ingredients.',
 'conze-dosing': 'Participants were instructed to take 4 capsules daily after breakfast beginning the day after their randomization visit (Day 1).',
 'truniagen-amount': 'Serving Size: 1 Vegetarian Capsule',
 'truniagen-niagen-300': 'NIAGEN® (nicotinamide riboside chloride) | 300mg',
 'truniagen-directions': 'Adults can take one capsule 1-3 times daily as needed or as recommended by your healthcare professional.',
 'fda-row-hypercholesterolemia': '| Hypercholesterolemia | Patients with heterozygous familial and nonfamilial hypercholesterolemia | Serum LDL cholesterol | Traditional | Lipid-lowering |',
 'fda-row-lal': '| Lysosomal Acid Lipase (LAL) deficiency | Patients with LAL deficiency | Serum LDL-c levels | Traditional | Hydrolytic lysosomal cholesteryl ester and triacylglycerol-specific enzyme |',
 'fda-context-dependent': 'A particular surrogate endpoint that may be appropriate for use in a particular drug or biologic clinical development program, should not be assumed to be appropriate for use in a different program that is in a different clinical setting.',
 'fda-best-categories': 'BEST defines seven biomarker categories: susceptibility/risk, diagnostic, monitoring, prognostic, predictive, pharmacodynamic/response, and safety.',
 'nadpark-primary': "The primary outcome will be the between-group difference in Parkinson's disease related pattern (PDRP) measured by FDG-PET comparing baseline and 3-4 week follow-up measurement.",
 'nadpark-secondary': 'Clinical changes measured by MDS-UPDRS from using NR',
 'nadpark-abstract-responders': 'NR recipients showing increased brain NAD levels exhibited altered cerebral metabolism, measured byfluoro-deoxyglucose positron emission tomography, and this was associated with mild clinical improvement.',
 'martineau-2017-or': 'Vitamin D supplementation reduced the risk of acute respiratory tract infection among all participants (adjusted odds ratio 0.88, 95% confidence interval 0.81 to 0.96; P for heterogeneity <0.001).',
 'martineau-2017-quality': 'The body of evidence contributing to these analyses was assessed as being of high quality.',
 'jolliffe-2021-or': 'with an OR of 0·92 (95% CI 0·86-0·99; 37 studies; I=35·6%, p=0·018).',
 'jolliffe-2025-or': 'For the primary comparison of any vitamin D versus placebo, the intervention did not statistically significantly affect overall ARI risk (OR 0·94 [95% CI 0·88–1·00], p=0·057; 40 studies; 61 589 participants;=26·4%).',
 'jolliffe-2025-subgroup': 'A statistically significant protective effect of vitamin D was seen for participants aged 1–15 years (OR 0·74 [95% CI 0·60–0·92]; 11 944 participants in 16 studies)',
 'jolliffe-2025-grade': 'the quality of the body of evidence contributing to analyses of the primary efficacy outcome and major secondary outcomes was downgraded to moderate',
 'jolliffe-2025-interpretation': 'the 95% CI for this effect estimate now includes 1·00, indicating no statistically significant protection.',
}
def nfcws1(s): return re.sub(r'\s+', ' ', unicodedata.normalize('NFC', s)).strip()
if __name__ == '__main__':
    for k, v in QUOTES.items():
        print(k, 'sha256:' + hashlib.sha256(nfcws1(v).encode('utf-8')).hexdigest())

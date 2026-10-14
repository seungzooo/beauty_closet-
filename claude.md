# Beauty Closet — AI 디지털 옷장 & 스타일링 웹앱

> 이 파일은 Claude Code가 이 저장소에서 개발할 때 따르는 **개발 요구사항 명세**입니다.
> 사업 분석용 원본 프롬프트는 [docs/business-master-prompt.md](docs/business-master-prompt.md)에 보관되어 있습니다.
> 표시 규칙: **[확정]** 결정된 사항 · **[가정]** 검증 전 가설(바뀔 수 있음) · **[TBD]** 미결정.

---

## 1. 제품 정의

| 항목 | 내용 |
|---|---|
| 한 줄 정의 | 내가 **이미 가진 옷**으로 매일 입을 코디를 AI가 제안하고, 그 이유를 설명하는 모바일 웹앱 |
| 해결할 문제 | "옷은 많은데 입을 게 없다" — 보유 의류 파악 불가, 조합 고민 시간, 활용 안 되는 옷, 중복 구매 |
| 1차 타깃 [가정] | 20~30대, 패션 관심도 중상, 옷 50벌 이상 보유, 매일 출근/등교 코디를 고민하는 사용자 |
| 플랫폼 [확정] | 모바일 우선 반응형 웹앱 (PWA, 홈 화면 추가 지원). 네이티브 앱은 범위 밖 |
| 원칙 [확정] | 특정 개인 취향용 앱이 아닌 **다양한 스타일을 수용하는 B2C 플랫폼**으로 설계. 스타일 태그·트렌드 데이터는 하드코딩하지 말고 설정/DB로 관리 |

### 핵심 가치 검증 가설 (MVP가 답해야 할 질문)
1. 사용자가 옷 **20벌 이상**을 등록할 만큼 등록 과정이 쉬운가? (가장 큰 이탈 지점)
2. 보유 옷 기반 AI 코디가 "실제로 입고 싶다"는 평가를 받는가? (👍 비율)
3. 사용자가 주 3회 이상 다시 방문하는가?

---

## 2. 기능 범위와 우선순위

### MVP (12주 내, 반드시 구현)
| ID | 기능 | 비고 |
|---|---|---|
| M1 | 회원가입/로그인 (이메일 + 소셜 1종) | |
| M2 | 온보딩: 추구미 선택, 체형/핏 선호, 성별 표현·사이즈(선택) | 3분 이내 완료 |
| M3 | 의류 사진 업로드 → 배경 제거 → AI 자동 분류 → 사용자 확인/수정 | 다중 업로드 지원 |
| M4 | 옷장 보기: 카테고리·색상·계절 필터, 검색, 상세/편집/삭제 | |
| M5 | 오늘의 코디 생성: 상황(TPO)·날씨 + 가중치 슬라이더 3종 | 보유 의류만 사용 |
| M6 | 추천 이유 설명 + 👍/👎 + 사유 선택 피드백 | |
| M7 | 코디 저장(룩북), "오늘 입음" 기록 | 착용 이력 → 활용도 분석의 원천 |
| M8 | 계정·데이터 전체 삭제, 개별 이미지 삭제 | 개인정보 필수 |
| M9 | 이벤트 로깅 (§9) | 가설 검증용 |

### P1 (MVP 검증 후)
- 스타일 레퍼런스 이미지 업로드 → 추구미 분석
- 옷장 활용도 리포트 (안 입은 옷, 착용 빈도, 카테고리 편중)
- 부족 아이템 분석 ("이 아이템 1개면 코디 N개 추가 가능")
- 코디 이미지 SNS 공유 카드 (바이럴 루프)
- 피드백 기반 개인화 가중치 자동 보정

### P2 (사업 확장)
- 유료 구독 (무제한 생성, 고급 리포트) — 결제 연동
- 제휴 커머스 (부족 아이템 → 제휴 상품 링크)
- B2B (브랜드/스타일리스트용 대시보드)

> **범위 밖 [확정]**: 가상 피팅(착용 이미지 합성), 체형 사진 분석, 실시간 트렌드 크롤링, 네이티브 앱, 커뮤니티 피드.
> 새 기능 요청이 들어오면 위 우선순위를 먼저 확인하고, MVP 범위를 벗어나면 구현 전에 사용자에게 확인할 것.

---

## 3. 기술 스택

> **[확정]** 코드 저장소 GitHub · DB/인증/스토리지 Supabase · 배포 Vercel (상세 §12).
> 그 외 항목은 [가정] — 변경 시 이 섹션부터 갱신.

| 영역 | 선택 | 이유 |
|---|---|---|
| 프레임워크 | Next.js (App Router) + TypeScript (strict) | 웹/API 일체형, 배포 간편 |
| UI | Tailwind CSS + shadcn/ui, 모바일 퍼스트 | |
| 백엔드/DB | Supabase (PostgreSQL, Auth, Storage, RLS) | 인증·스토리지·권한을 한 번에 |
| AI (분류·설명) | Claude API — 비전 분류 `claude-sonnet-5-5`, 경량 작업 `claude-haiku-5-5` | 이미지 이해 + 구조화 출력 |
| 배경 제거 | 클라이언트 측 `@imgly/background-removal` (실패 시 원본 사용) | 서버 비용 0 |
| 날씨 | 기상청 단기예보 API 또는 OpenWeatherMap [TBD] | |
| 검증 | Zod (API 입력/AI 출력 스키마) | |
| 테스트 | Vitest (단위), Playwright (E2E 핵심 플로우) | |
| 저장소/CI [확정] | GitHub + GitHub Actions | PR마다 자동 검사 |
| 배포 [확정] | Vercel (GitHub 연동 자동 배포) + Supabase Cloud | Next.js 공식 호스팅 |

### 디렉터리 구조
```
beauty_closet/
├─ app/                    # Next.js 라우트 (화면 = §7)
│  ├─ (auth)/              # 로그인, 가입
│  ├─ onboarding/
│  ├─ closet/              # 옷장 목록, [id] 상세, upload
│  ├─ outfit/              # 오늘의 코디, 룩북
│  ├─ settings/            # 프로필, 데이터 삭제
│  └─ api/                 # Route Handlers
├─ lib/
│  ├─ ai/                  # Claude 호출, 프롬프트, 출력 스키마
│  ├─ recommend/           # 추천 엔진 (순수 함수, AI 의존 없음)
│  ├─ db/                  # Supabase 클라이언트, 쿼리
│  └─ analytics/           # 이벤트 로깅
├─ components/
├─ config/                 # 스타일 태그, 트렌드 태그, 색상 조화·핏 규칙 (JSON)
├─ supabase/migrations/    # SQL 마이그레이션
├─ tests/
└─ docs/
```

---

## 4. 데이터 모델

```
profiles         id(=auth.uid), nickname, gender_expression?, body_shape?, preferred_fit[],
                 style_prefs jsonb {tag: weight}, default_weights jsonb, region, created_at
clothing_items   id, user_id, image_path, image_cutout_path, category, subcategory,
                 color_primary, color_secondary?, pattern, material?, seasons[],
                 formality(1-5), fit, style_tags[], ai_confidence, user_verified bool,
                 wear_count, last_worn_at?, archived bool, created_at
outfits          id, user_id, item_ids uuid[], context jsonb {occasion, temp, weather},
                 weights jsonb {style, fit, trend}, score, score_breakdown jsonb,
                 explanation text, source('ai'|'manual'), saved bool, created_at
outfit_feedback  id, outfit_id, user_id, rating(+1|-1), reasons[], comment?, created_at
wear_logs        id, user_id, outfit_id?, item_ids[], worn_on date
style_references (P1) id, user_id, image_path, extracted_tags jsonb
events           id, user_id?, name, props jsonb, created_at
```

- 모든 사용자 테이블에 **RLS: `user_id = auth.uid()`** 적용. 예외 없음.
- 이미지 Storage 버킷은 비공개, 서명 URL(만료 1시간)로만 접근.
- 분류 값(category, pattern, style_tags 등)은 `config/`의 열거형과 일치해야 하며 Zod로 검증.

### 분류 체계 [확정, 확장 가능]
- category: `top | bottom | outer | dress | shoes | bag | accessory`
- pattern: `solid | stripe | check | dot | floral | graphic | other`
- seasons: `spring | summer | fall | winter`
- fit: `slim | regular | oversized`
- style_tags 예시: `minimal, casual, street, classic, romantic, sporty, office, vintage` (config에서 관리)

---

## 5. 기능 상세 명세 (수용 기준 포함)

### M3. 의류 등록 & 자동 분류
1. 사용자가 사진 1~10장 선택 (카메라/갤러리). 클라이언트에서 긴 변 1024px로 리사이즈, EXIF(위치정보) 제거.
2. 배경 제거 → 원본/누끼 이미지 Storage 업로드.
3. 서버에서 Claude 비전 호출 → §4 스키마의 JSON 반환 (Zod 검증, 실패 시 1회 재시도 후 "수동 입력" 폼으로).
4. 확인 화면: AI 추정값을 미리 채운 편집 폼. `ai_confidence < 0.6` 필드는 강조 표시.
5. 저장 시 `user_verified = true`.

**수용 기준**: 단일 의류 사진 기준 업로드→확인 화면까지 p90 10초 이내 · 한 사진에 여러 옷이 있으면 "옷 하나씩 찍어주세요" 안내 · 분류에 실패해도 등록은 가능.

### M5. 코디 추천
- 입력: 상황(출근/데이트/운동/여행/일상 등), 날씨(위치 기반 자동, 수동 변경 가능), 가중치 슬라이더 3종(추구미 / 체형·핏 / 트렌드, 합계 100%로 자동 정규화).
- 출력: 코디 3안. 각 안 = 아이템 목록(이미지 콜라주) + 점수 구성 + 2~3문장 설명.
- 보유 옷이 부족해 조합할 수 없으면: 필요한 카테고리를 알려주고 등록 유도 (보유하지 않은 옷을 지어내지 않음).
- **수용 기준**: 생성 p90 5초 이내 · 최근 3일 내 추천/착용한 동일 조합 제외 · 같은 입력으로 다시 생성하면 다른 결과.

### M6. 설명 & 피드백
- 설명은 실제 점수 근거(색 조화, 계절 적합, 선호 태그 일치 등)에서 생성. 근거 없는 칭찬 문구 금지.
- 👎 시 사유 선택: `색 조합 / 핏 / 상황에 안 맞음 / 내 스타일 아님 / 날씨 / 기타`.
- 피드백은 `outfit_feedback`에 저장하고 P1의 개인화 보정에 사용.

### M8. 데이터 삭제
- 설정 > 계정 삭제: 확인 2단계 → DB 행 + Storage 파일 **즉시 삭제** (soft delete 아님). 이벤트 로그는 user_id를 null 처리.
- 개별 의류 삭제 시 원본/누끼 이미지 모두 삭제.

---

## 6. 추천 알고리즘

AI에게 조합 자체를 맡기지 않는다. **규칙 기반 후보 생성 + 점수화는 `lib/recommend/`의 결정적 순수 함수**로 구현하고, LLM은 설명 생성(및 선택적 재정렬)에만 사용한다. → 비용·지연·재현성·테스트 가능성 확보.

### 6.1 파이프라인
```
1. 필터    : archived 제외, 계절/기온 부적합 제외, formality가 상황 범위 밖이면 제외
2. 후보생성: 템플릿 조합 (top+bottom+shoes [+outer if 기온<17℃] [+bag]) 또는 (dress+shoes ...)
             후보가 많으면 무작위 샘플링, 상한 300개
3. 하드제약: 색 조화 점수 < 임계값, 포멀도 편차 > 2 인 조합 제거
4. 점수화  : 아래 공식
5. 다양성  : 상위권에서 아이템 중복을 최소화하며 3안 선택 (MMR 방식)
6. 설명    : 3안의 score_breakdown을 Claude(haiku)에 전달 → 사용자 언어로 설명
```

### 6.2 점수 공식
```
Score = C × (w_s·S_style + w_f·S_fit + w_t·S_trend) − P_repeat

C        기본 호환도 (0~1): 색 조화 · 패턴 충돌 · 포멀도 일관성 · 날씨 적합의 평균
S_style  아이템 style_tags와 사용자 style_prefs의 가중 일치도 (0~1)
S_fit    선호 핏·체형 규칙과의 일치도 (0~1), 규칙은 config/fit_rules.json
S_trend  config/trends.json 의 현재 시즌 트렌드 태그 일치도 (0~1)
w_*      사용자 슬라이더 값, 합 = 1
P_repeat 최근 착용/추천 감점
```
- 트렌드 데이터 [가정]: MVP는 운영자가 월 1회 수동 갱신하는 JSON. 자동 수집은 범위 밖.
- 체형 규칙은 고정관념을 강요하지 않도록 "선호 핏" 우선, 체형은 사용자가 입력한 경우에만 약하게 반영.
- 각 하위 점수는 단위 테스트로 고정 (예: 네이비+화이트 > 레드+그린 색 조화).

---

## 7. 화면 구성 (IA)

```
하단 탭: [오늘 코디] [옷장] [+ 등록] [룩북] [MY]

오늘 코디  상황 칩 · 날씨 카드 · 가중치 슬라이더(접힘) · 코디 3안 카드(스와이프) · 👍👎 · 저장/입음
옷장       필터 바 · 2~3열 그리드 · 아이템 상세(속성 편집, 착용 횟수, 이 옷이 들어간 코디)
등록       사진 선택 → 진행 상태 → 확인/수정 폼(여러 장이면 스와이프)
룩북       저장 코디 목록 · 착용 캘린더
MY         프로필/추구미 수정 · 기본 가중치 · 데이터 내보내기·삭제 · (P1) 활용도 리포트
```
- 첫 진입(빈 옷장): "옷 5벌만 등록하면 첫 코디를 받아볼 수 있어요" + 진행 바. 코디 생성 최소 조건: top 2, bottom 2, shoes 1.
- 터치 영역 최소 44px, 375px 폭 기준 디자인, 다크 모드 지원.

---

## 8. AI 연동 규칙

- API 키는 서버에서만 사용 (`ANTHROPIC_API_KEY`), 클라이언트 노출 금지.
- 프롬프트는 `lib/ai/prompts/`에 파일로 관리, 출력은 반드시 JSON 스키마 + Zod 검증.
- 사용자 입력 텍스트(코멘트 등)는 프롬프트에 데이터로만 삽입하고 지시문과 구분.
- 비용 통제 [가정]: 사용자당 일일 분류 50장 / 코디 생성 20회 제한, 동일 입력 설명 결과 캐시.
- AI 장애 시 폴백: 분류 → 수동 입력, 설명 → score_breakdown 기반 템플릿 문장.
- 호출마다 모델명·토큰 수·지연시간을 `events`에 기록 (원가 분석용).

---

## 9. 측정 지표 & 이벤트

| 이벤트 | 용도 |
|---|---|
| `signup_completed`, `onboarding_completed` | 획득·온보딩 퍼널 |
| `item_uploaded`, `item_verified`, `item_edited_fields` | 등록 마찰, 분류 정확도(수정된 필드 비율) |
| `outfit_generated`, `outfit_feedback`, `outfit_saved`, `outfit_worn` | 추천 품질 |
| `weights_changed` | 가중치 기능 사용 여부 |
| `share_clicked` (P1) | 바이럴 |

- **활성화 정의 [가정]**: 가입 후 7일 내 의류 20벌 등록 + 코디 1회 이상 저장 또는 착용.
- **핵심 KPI**: 활성화율, 분류 필드 수정률, 👍 비율, W1/W4 리텐션, 주간 코디 생성 수.
- Go/Pivot 판단 기준값은 첫 베타 코호트 결과로 정하고 docs/에 기록할 것.

---

## 10. 개인정보 & 보안

- 수집 최소화: 체형·성별 표현·사이즈는 **선택 항목**. 사진은 옷만 찍도록 안내 (얼굴·신체 사진 지양).
- 업로드 이미지 EXIF 제거, 비공개 버킷, RLS 필수.
- 개인정보 처리방침·이용약관 페이지 (MVP 출시 전 필수), AI 학습 활용 여부 명시 [TBD].
- 이미지 데이터를 모델 학습/외부 공유에 쓰려면 별도 동의 필요 — 기본값은 미사용.

---

## 11. 개발 규칙 (Claude Code 작업 지침)

- 언어: 코드·커밋 메시지는 영어, UI 문구·문서는 한국어.
- 작은 단위로 구현하고, 기능 하나가 끝날 때마다 타입 체크·린트·테스트 통과 확인.
- `lib/recommend/`는 외부 의존 없는 순수 함수 + 단위 테스트 필수.
- DB 스키마 변경은 `supabase/migrations/`에 SQL로만. 이 문서 §4도 함께 갱신.
- 비밀값은 `.env.local` (커밋 금지), 필요한 키 목록은 `.env.example`에 유지 (§12.4).
- `git push`, Vercel 프로덕션 배포, 운영 DB(`prod`)에 마이그레이션 적용은 **사용자 확인 후** 실행.
- 범위 밖 기능(§2)이나 기술 스택 변경은 구현 전에 사용자에게 확인.
- 근거 없는 수치(전환율, 시장 규모 등)를 코드·문서에 넣을 때는 [가정] 표시.

### 명령어 (프로젝트 생성 후 갱신)
```
npm run dev        # 개발 서버
npm run build      # 프로덕션 빌드
npm run lint       # ESLint
npm run typecheck  # next typegen + tsc --noEmit
npm test           # Vitest (미설정)
npm run test:e2e   # Playwright (미설정)
npm run db:types   # supabase gen types → lib/db/database.types.ts
```

---

## 12. 배포 & 인프라 (GitHub · Supabase · Vercel)

### 12.1 전체 흐름
```
로컬 개발 ──push──▶ GitHub (feature 브랜치) ──PR──▶ GitHub Actions 검사 + Vercel Preview 배포
                                                         │  (Preview는 Supabase dev 프로젝트 사용)
                                              merge ▼
                                         main 브랜치 ──▶ Vercel Production 배포 (Supabase prod 프로젝트)
DB 스키마: supabase/migrations/*.sql ──▶ dev에 먼저 적용·검증 ──▶ 사용자 확인 후 prod 적용
```

### 12.2 GitHub
- 저장소 [확정]: https://github.com/seungzooo/beauty_closet- (공개 public). 기본 브랜치 `main` = 프로덕션.
- 공개 저장소이므로 비밀값·실사용자 데이터·시드용 실제 사진은 절대 커밋하지 않는다.
- 브랜치: `feat/<기능>`, `fix/<내용>` → PR → 검사 통과 후 `main`에 merge. `main` 직접 push 금지 (브랜치 보호 규칙).
- 커밋 메시지: Conventional Commits (`feat:`, `fix:`, `chore:`, `db:` …), 영어.
- `.gitignore` 필수 항목: `.env*` (단 `.env.example` 제외), `.vercel/`, `node_modules/`, `.next/`, `supabase/.temp/`.
- GitHub Actions (`.github/workflows/ci.yml`): PR·push 시 `npm ci → lint → typecheck → test → build`. 실패하면 merge 불가.

### 12.3 Supabase (DB)
- 프로젝트 2개 [가정]: `beauty-closet-dev` (개발·Preview) / `beauty-closet-prod` (운영). 무료 플랜은 조직당 활성 프로젝트 2개까지이며, 일정 기간 미사용 시 일시 정지될 수 있음.
- CLI는 전역 설치 없이 `npx supabase` 로 사용 (devDependency로 추가).
- 스키마 관리 규칙 — **대시보드에서 직접 테이블을 만들거나 수정하지 않는다.**
  1. `npx supabase migration new <이름>` 으로 SQL 파일 생성
  2. 테이블 + **RLS 정책 + Storage 버킷/정책**을 같은 마이그레이션에 작성
  3. `npx supabase db push` 로 dev에 적용 → 동작 확인
  4. `npm run db:types` 로 TypeScript 타입 재생성 후 커밋
  5. prod 적용은 사용자 확인 후 `npx supabase link --project-ref <prod>` → `db push`
- 로컬 Supabase(`supabase start`)는 Docker가 필요하므로 선택 사항. 기본은 dev 원격 프로젝트로 개발.
- 시드 데이터: `supabase/seed.sql` (테스트 계정·샘플 의류, dev 전용).
- Auth 설정: Site URL = 프로덕션 도메인, Redirect URL에 `http://localhost:3000/**`, Vercel Preview 도메인(`https://*-<팀>.vercel.app/**`) 추가.
- Storage 버킷: `clothing-images` (비공개). 경로 규칙 `{user_id}/{item_id}/original.webp`, `cutout.png`. 정책은 경로의 첫 폴더가 `auth.uid()`일 때만 허용.

### 12.4 Vercel (배포)
- GitHub 저장소를 Vercel 프로젝트에 연결(Import) → `main` push 시 Production, PR마다 Preview URL 자동 생성.
- 환경 변수 (Vercel 대시보드 + `.env.example`에 키 이름만 기록):

| 변수 | 공개 여부 | Production | Preview / Development |
|---|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | 공개 | prod | dev |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (구 anon key) | 공개 | prod | dev |
| `SUPABASE_SECRET_KEY` (구 service_role key) | **서버 전용** | prod | dev |
| `ANTHROPIC_API_KEY` | **서버 전용** | 운영 키 | 개발 키 (사용량 한도 설정) |
| `WEATHER_API_KEY` | 서버 전용 | ✓ | ✓ |

- `SUPABASE_SECRET_KEY`는 RLS를 우회하므로 계정 삭제(M8) 등 서버 라우트에서만 사용, 클라이언트 번들에 절대 포함 금지.
- AI 호출 라우트는 실행 시간이 길 수 있으므로 Route Handler에 `export const maxDuration` 지정, 이미지 업로드는 서버를 거치지 않고 **클라이언트 → Supabase Storage 직접 업로드** (Vercel 요청 크기 제한 회피).
- 리전: Vercel Functions 리전을 Supabase 프로젝트 리전과 같게 설정 (예: 서울 `icn1` ↔ Supabase `ap-northeast-2`) [가정].
- 요금제 주의 [확인 필요]: Vercel Hobby 플랜은 비상업용. 유료 구독·커머스 등 상업 운영 시작 전 Pro 플랜 전환 필요.

### 12.5 프로덕션 배포 체크리스트
- [ ] CI 통과, Preview에서 핵심 플로우(가입 → 등록 → 코디 생성 → 삭제) 수동 확인
- [ ] prod Supabase에 모든 마이그레이션 적용, RLS 활성화 확인 (Supabase Advisors 경고 0건)
- [ ] Vercel Production 환경 변수 설정, 비밀 키가 `NEXT_PUBLIC_`으로 노출되지 않았는지 확인
- [ ] Auth Redirect URL·커스텀 도메인 설정
- [ ] 개인정보 처리방침·이용약관 페이지 게시

### 12.6 로컬 도구 현황 (2026-10-14 기준)
- 설치됨: Node 24, npm 11, git 2.54, Vercel CLI 63
- 미설치: GitHub CLI(`gh`) — 저장소 생성은 웹에서 하거나 `gh` 설치 후 진행 · Supabase CLI — `npx supabase`로 대체

---

## 13. 12주 MVP 로드맵

| 주차 | 목표 | 산출물 |
|---|---|---|
| 1 | 셋업 | Next.js 프로젝트, GitHub 저장소·CI, Supabase dev/prod 생성, 첫 마이그레이션(스키마/RLS), 인증, **Vercel 첫 배포(빈 앱)** |
| 2 | 온보딩 | M1·M2, 프로필 저장 |
| 3–4 | 등록 | M3 업로드·배경 제거·AI 분류·확인 폼 |
| 5 | 옷장 | M4 목록·필터·편집·삭제 |
| 6–7 | 추천 엔진 | §6 파이프라인, 단위 테스트, 날씨 연동 |
| 8 | 코디 UI | M5·M6 화면, 설명 생성, 피드백 |
| 9 | 기록 | M7 룩북·착용 기록, M8 데이터 삭제 |
| 10 | 계측·품질 | M9 이벤트, 성능 목표 달성, E2E 테스트 |
| 11 | 클로즈드 베타 | prod 배포(§12.5 체크리스트), 20~30명 테스트, 인터뷰, 버그 수정 |
| 12 | 판단 | KPI 리뷰 → P1 우선순위 결정 (Go/Pivot/Stop) |

> 1주차부터 Vercel에 배포해 두고 기능마다 Preview로 확인한다. 마지막 주에 처음 배포하지 않는다.

---

## 14. 지금 단계에서 피해야 할 결정

1. 등록 마찰을 검증하기 전에 가상 피팅·커머스 같은 화려한 기능부터 만드는 것
2. 추천 조합 생성을 전부 LLM에 맡기는 것 (비용·재현성·테스트 불가)
3. 개인정보 처리 설계 없이 체형/얼굴 데이터를 수집하는 것

## 15. 미결정 사항 [TBD]
- Vercel 팀/개인 계정, 커스텀 도메인
- 소셜 로그인 제공자 (카카오 / 구글 / 애플)
- 날씨 API 선택
- 서비스 정식 명칭 및 브랜드 톤
- 구독 가격 가설 (P2 전에 가격 실험으로 결정)

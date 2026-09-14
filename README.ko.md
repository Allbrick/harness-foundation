# harness-foundation

*[English](README.md) · 한국어*

AI Coding Agent를 위한 재사용 가능한 **Harness**입니다. 여러 프로젝트에서 Agent 기반 개발을 반복
가능하게 만드는 운영 원칙, 역할, 절차, 안전 정책을 담고 있습니다.

Claude Code를 우선 지원합니다. 내용 자체는 의도적으로 특정 도구에 종속되지 않게 작성되어 다른 Agent로
옮길 수 있습니다 — [`docs/portability.md`](docs/portability.md) 참고.

---

## Harness Engineering이란

**Prompt**는 한 번 입력하는 지시입니다. **Harness**는 모델 주위의 구조로, 매번 부탁하지 않아도 좋은
행동이 기본값이 되게 만듭니다. Agent가 무엇을 언제 알게 되는지, 어떤 종류의 작업을 누가 맡는지, 반복되는
작업이 어떤 절차로 수행되는지, 그리고 애초에 무엇이 허용되지 않는지를 정의합니다.

이 구분이 중요한 이유는, Agent의 나쁜 결과 대부분이 **문장을 더 잘 쓴다고 해결되지 않기** 때문입니다.
해결은 구조적으로 이루어집니다 — 역할에서 도구를 제거하거나, deny 규칙을 추가하거나, 절차가 행동 이전에
근거를 요구하도록 만드는 식입니다. Harness는 버전 관리되고, diff로 리뷰할 수 있으며, 시간이 지나며
개선됩니다. Prompt는 그중 어느 것도 아닙니다.

전체 설계 철학: [`docs/harness-engineering.md`](docs/harness-engineering.md).

## 이 저장소가 해결하려는 문제

Harness 없이 Coding Agent와 작업하면 익숙한 실패들이 반복됩니다.

| 실패 | Harness의 대응 |
| --- | --- |
| 아무것도 실행하지 않고 작업을 완료로 보고 | 모든 절차가 Validation 체크리스트로 끝나고, 모든 리포트는 *검증하지 못한 것*을 명시해야 함 |
| 존재하지 않는 `npm test` 같은 명령을 지어냄 | `test` skill은 Discovery로 시작하고, "명령을 지어내지 않는다"가 상시 규칙 |
| 요청 범위를 훨씬 넘어서 수정 | 최소 변경 원칙, 영향 범위를 명시한 Plan 우선 |
| 자기가 짠 코드를 자기가 리뷰하고 승인 | `reviewer`와 `architect`에 파일 편집 도구가 없음 |
| 증상이 사라질 때까지 코드를 고치며 버그 수정 | `debugger`에 편집 도구가 없고, 증거·가설 기반 절차를 따름 |
| 매 세션 같은 지적을 다시 입력 | 반복되는 지적은 Skill로 승격 |
| 파괴적인 명령을 실행 | 파괴적 명령과 secret 파일에 대한 deny 규칙 |

## Claude Code에서 빠르게 시작하기

```bash
git clone https://github.com/Allbrick/harness-foundation.git
```

Harness **자체를 작업**하려면 이 저장소를 열면 됩니다 — `CLAUDE.md`, agents, skills가 자동으로
로드됩니다. **다른 프로젝트에 적용**하려면 [프로젝트에 적용하기](#프로젝트에-적용하기)를 보세요.

프로젝트에 설치한 뒤에는:

| 하고 싶은 일 | 사용할 것 |
| --- | --- |
| 변경 계획 수립 | `plan` skill, 규모가 크면 `architect` agent |
| 승인된 계획 구현 | `implement` skill 또는 `implementer` agent |
| diff 리뷰 | `review` skill 또는 `reviewer` agent |
| 버그 진단 | `debug` skill 또는 `debugger` agent |
| 동작 변경 없는 구조 개선 | `refactor` skill |
| 테스트 실행/작성 | `test` skill |
| 커밋 | `commit` skill |

Harness 자체는 언제든 다음으로 검증할 수 있습니다:

```bash
bash scripts/validate-harness.sh
```

## CLAUDE.md / agents / skills / settings의 차이

네 레이어는 서로 다른 일을 합니다. 이것을 섞는 것이 Harness가 망가지는 가장 흔한 경로입니다.

| 레이어 | 답하는 질문 | 위치 | 로드 시점 |
| --- | --- | --- | --- |
| **Principles** | Agent가 항상 어떻게 행동해야 하는가? | `CLAUDE.md` | 항상 Context에 존재 |
| **Agents** | 이런 종류의 일을 *누가*, 어떤 도구로 하는가? | `.claude/agents/` | description은 항상, 본문은 선택 시 |
| **Skills** | 이 작업을 *어떻게* 단계별로 수행하는가? | `.claude/skills/` | description은 항상, 본문은 선택 시 |
| **Settings** | 무엇이 허용/확인/금지되는가? | `.claude/settings.json` | 모든 도구 호출마다 런타임이 강제 |

판단 기준:

- 항상 관련 있고 한 줄로 끝난다 → `CLAUDE.md`
- 책임과 권한에 관한 것 → **Agent**
- 반복 가능한 단계의 나열 → **Skill**
- 대화 내용과 무관하게 지켜져야 한다 → **Settings**, 또는 더 좁은 도구 권한
- *왜*를 설명한다 → [`docs/`](docs/), 필요할 때만 로드
- 런타임이 이미 제공한다 → **다시 만들지 않는다.** 그 위에 합성한다
  ([`docs/skill-design.md`](docs/skill-design.md#do-not-reimplement-what-the-runtime-already-does) 참고)

이 계층 구조가 [Progressive Disclosure](docs/harness-engineering.md#progressive-disclosure)입니다.
Context는 "언젠가 중요할지 모르는 모든 것"이 아니라 "지금 이 판단을 바꾸는 것"에만 씁니다.

## 구성 요소

### Agents — [`docs/agent-design.md`](docs/agent-design.md)

| Agent | 책임 | 파일 수정 |
| --- | --- | --- |
| [`architect`](.claude/agents/architect.md) | 요구사항, 코드베이스 분석, 영향 범위, 설계, 계획 | 불가 |
| [`implementer`](.claude/agents/implementer.md) | 승인된 계획 실행, 테스트, 검증 | 가능 |
| [`reviewer`](.claude/agents/reviewer.md) | 최종 verdict 소유: generic pass는 위임하고 프로젝트 레이어를 추가 | 불가 |
| [`debugger`](.claude/agents/debugger.md) | 재현, 증거, 가설, 근본 원인, 최소 수정안 | 불가 |

`architect` · `reviewer` · `debugger`에 편집 도구가 없는 것은 문장이 아니라 **능력 제한**입니다.
"하면 안 된다"보다 "할 수 없다"가 강합니다.

### Skills — [`docs/skill-design.md`](docs/skill-design.md)

| Skill | 절차 |
| --- | --- |
| [`plan`](.claude/skills/plan/SKILL.md) | 요구사항 → 관련 코드 → 아키텍처 → 영향 범위 → 위험 → 순서가 있는 단계 |
| [`implement`](.claude/skills/implement/SKILL.md) | 재확인 → 기존 관례에 맞춘 최소 변경 → 테스트 → 검증 → diff 검토 |
| [`review`](.claude/skills/review/SKILL.md) | generic pass는 내장 `/code-review`에 위임하고, architecture boundary · 프로젝트 convention · 도메인 규칙을 더함 |
| [`debug`](.claude/skills/debug/SKILL.md) | 증상 → 재현 → 증거 → 가설 → 근본 원인 → 최소 수정 → 회귀 테스트 |
| [`refactor`](.claude/skills/refactor/SKILL.md) | 동작을 고정한 채 구조만 변경하고, 전후 동등성을 증명 |
| [`test`](.claude/skills/test/SKILL.md) | 실제 테스트 환경을 먼저 탐색. 명령을 지어내지 않음 |
| [`commit`](.claude/skills/commit/SKILL.md) | diff 분석, 논리적 그룹화, Conventional Commits |

### Personal Skills — [`personal-skills/README.md`](personal-skills/README.md)

Harness *자체를* 다루는 Skill입니다. 대상 프로젝트에 들어가기 전에 있어야 하므로 `~/.claude/skills/`에
설치해 모든 로컬 저장소에서 쓸 수 있게 합니다.

| Skill | 목적 |
| --- | --- |
| [`adopt-harness`](personal-skills/adopt-harness/SKILL.md) | 기존 상태 조사 → 증거 기반으로 저장소 재구성 → 검증된 project profile 작성 → 각 발견을 강제 가능한 계층에 배치 |
| [`audit-harness`](personal-skills/audit-harness/SKILL.md) | 저장소와 그것을 설명하는 Harness 사이의 drift 탐지 — 낡은 명령, 교체된 아키텍처, 더 이상 작동하지 않는 guardrail |

### Workflow — [`docs/workflow.md`](docs/workflow.md)

```text
Explore → Understand → Plan → Implement → Validate → Review → Report
```

작업 규모에 맞춰 조절합니다. 한 줄 수정은 한 턴 안에서 암묵적으로 돌고, 여러 모듈에 걸친 변경은 Agent를
분리해 명시적으로 돕니다 (`architect → implementer → reviewer`, 버그는
`debugger → implementer → reviewer`). 단계는 생략할 수 있지만 **말없이 생략해서는 안 됩니다.**

## 프로젝트에 적용하기

```bash
cd <your-project>
mkdir -p .claude
cp -r <path-to>/harness-foundation/.claude/agents .claude/agents
cp -r <path-to>/harness-foundation/.claude/skills .claude/skills
cp    <path-to>/harness-foundation/templates/settings.template.json .claude/settings.json
cp    <path-to>/harness-foundation/templates/CLAUDE.template.md CLAUDE.md   # 이후 채워 넣기
```

또는 `adopt-harness`를 한 번 설치해두고 증거 기반으로 대신 시킬 수 있습니다:

```bash
cp -r personal-skills/adopt-harness personal-skills/audit-harness ~/.claude/skills/
# 이후 대상 프로젝트에서:  /adopt-harness
```

그다음 `CLAUDE.md`를 **그 저장소의 실제 증거로부터** 채웁니다 — 스택은 manifest와 lockfile에서, 명령은
task runner나 CI 설정에서, 아키텍처는 요청 하나를 처음부터 끝까지 따라가며. 출처를 댈 수 없는
placeholder는 지웁니다. **지어낸 명령은 빠진 명령보다 나쁩니다.**

마지막으로 그 프로젝트의 실제 검증 명령을 `.claude/settings.json`의 `allow`에 추가해, 검증할 때마다
권한 프롬프트가 뜨지 않게 합니다.

단계별로 "잘 된 결과"가 어떤 모습인지까지 포함한 전체 walkthrough:
[`examples/adopting-an-existing-project.md`](examples/adopting-an-existing-project.md).

## 새로운 Agent 추가하기

1. [`docs/agent-design.md`](docs/agent-design.md)를 읽습니다. 특히 새 역할이 **필요 없는** 경우를
   먼저 확인하세요 (대부분의 경우 정답은 Skill입니다).
2. [`templates/agent.template.md`](templates/agent.template.md)를 `.claude/agents/<name>.md`로 복사합니다.
3. **언제** 쓰는 역할인지 말해주는 `description`을 쓰고, `tools`는 **최소한**만 부여합니다.
4. 위 구성 요소 표에 추가하고 `bash scripts/validate-harness.sh`를 실행합니다.

## 새로운 Skill 추가하기

1. [`docs/skill-design.md`](docs/skill-design.md)를 읽습니다. 같은 지시를 세 번 입력했다면 Skill로
   승격할 때입니다 — 그리고 **먼저 내장 기능이 있는지 확인하세요.** 런타임이 일부라도 이미 하고 있다면,
   Skill은 그것을 다시 구현하지 않고 그 위에 합성합니다. `review`가 그 예시입니다.
2. [`templates/skill.template.md`](templates/skill.template.md)를
   `.claude/skills/<name>/SKILL.md`로 복사합니다.
3. 일곱 개 섹션을 모두 채웁니다 — 그 파일의 가치를 만드는 것은 `Failure handling`입니다.
4. 위 구성 요소 표에 추가하고 `bash scripts/validate-harness.sh`를 실행합니다.

## 프로젝트에 맞게 커스터마이징

| 필요한 것 | 들어갈 위치 |
| --- | --- |
| 스택, 명령, 아키텍처, 제약 | 템플릿으로 만든 그 프로젝트의 `CLAUDE.md` |
| 그 코드베이스 고유의 절차 | 그 프로젝트의 `.claude/skills/`에 새 Skill |
| 도메인 특화 역할 | 그 프로젝트의 `.claude/agents/`에 새 Agent |
| 그 프로젝트의 검증 명령 허용 | 그 프로젝트 `.claude/settings.json`의 `allow` |
| Harness 전체의 기본값 변경 | 이 저장소 (모든 프로젝트가 상속) |

도입이 무너지지 않게 하는 두 가지 규칙: 프롬프트를 없애려고 **`deny`를 완화하지 말 것**, 그리고
**프로젝트 고유 명령을 Harness에 넣지 말 것**. 후자는 프로젝트의 것이며, 여기에 박아 넣으면 Agent에게
"명령은 추측해도 된다"고 가르치는 셈입니다.

## 저장소 구성

```text
CLAUDE.md            항상 로드되는 운영 원칙
.claude/             agents, skills, 권한 정책 (정본 정의)
docs/                설계 근거 — 자동 로드되지 않고 필요할 때만
personal-skills/     Harness 도입·감사를 위한 운영자 Skill
templates/           프로젝트 · Agent · Skill의 출발점
examples/            실제 도입 walkthrough
scripts/             의존성 없는 구조 자체 검증
```

이 저장소에는 패키지 매니저도, 빌드 시스템도, 테스트 러너도 없으며 필요하지도 않습니다. 내용은 Markdown과
JSON 정책 파일 하나뿐입니다. [`docs/architecture.md`](docs/architecture.md) 참고.
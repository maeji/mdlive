# Claude Code 연동

Claude Code 가 `.md` / `.html` 파일을 **쓰거나 고칠 때마다** 자동으로 mdlive
미리보기 창을 띄웁니다. `--watch` 로 실행되므로, 이후 같은 파일을 계속 수정하면
창이 실시간으로 갱신됩니다(스트리밍처럼 글이 채워지는 게 보입니다).

## 설치

1. mdlive 를 빌드해 PATH 에 둡니다.

   ```bash
   swift build -c release
   cp .build/release/mdlive /usr/local/bin/
   ```

2. 훅 스크립트에 실행 권한을 줍니다.

   ```bash
   chmod +x integrations/mdlive-open.sh integrations/claude-code/mdlive-hook.sh
   ```

3. `~/.claude/settings.json` 에 PostToolUse 훅을 추가합니다.
   (`/절대/경로`는 이 저장소 위치로 바꾸세요.)

   ```json
   {
     "hooks": {
       "PostToolUse": [
         {
           "matcher": "Write|Edit",
           "hooks": [
             {
               "type": "command",
               "command": "/절대/경로/mdlive/integrations/claude-code/mdlive-hook.sh"
             }
           ]
         }
       ]
     }
   }
   ```

## 동작

- `Write` / `Edit` 도구가 실행되면 훅이 `tool_input.file_path` 를 읽습니다.
- 그 파일이 `.md` / `.markdown` / `.html` / `.htm` 이면 mdlive 를 `--watch` 로 띄웁니다.
- 같은 파일을 이미 보고 있으면 새 창을 띄우지 않습니다(기존 창이 자동 갱신).

> 특정 파일만 자동 미리보기하고 싶다면 `mdlive-open.sh` 의 `case` 패턴을
> 좁히거나, `matcher` 를 조정하세요.

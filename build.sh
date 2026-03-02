#!/bin/bash
REPO="supremeauthor856/LiveContainer-FS"
echo "🚀 Triggering build..."
gh workflow run build.yml --repo "$REPO" -f signing_method=enterprise
sleep 8
RUN_ID=$(gh run list --repo "$REPO" --workflow build.yml --limit 1 --json databaseId --jq '.[0].databaseId')
echo "📋 Run ID: $RUN_ID"
gh run watch "$RUN_ID" --repo "$REPO"
STATUS=$(gh run view "$RUN_ID" --repo "$REPO" --json conclusion --jq '.conclusion')
if [ "$STATUS" = "success" ]; then
  echo "✅ SUCCESS! Downloading IPA..."
  gh run download "$RUN_ID" --repo "$REPO" --dir ~/ipa
  ls -lh ~/ipa/
else
  echo "❌ FAILED — errors:"
  gh run view "$RUN_ID" --repo "$REPO" --log-failed 2>&1 | grep "error:" | grep -v "^Binary" | sed 's|/Users/runner/work/LiveContainer-FS/LiveContainer-FS/||g' | head -30
fi

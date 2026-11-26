<!DOCTYPE html>
<html lang="ru" class="dark">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Luau AI Script Builder & Payload Injector</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet" />
  <script>
    tailwind.config = {
      darkMode: 'class',
      theme: {
        extend: {
          fontFamily: {
            sans: ['Inter', 'system-ui', 'sans-serif'],
            mono: ['JetBrains Mono', 'ui-monospace', 'SFMono-Regular', 'monospace'],
          },
          colors: {
            surface: {
              950: '#090b10',
              900: '#0f131c',
              850: '#151b27',
              800: '#1c2434',
            },
          },
        },
      },
    };
  </script>
  <style>
    * {
      box-sizing: border-box;
    }
    html, body {
      background-color: #090b10;
      color: #f1f5f9;
      font-family: 'Inter', system-ui, sans-serif;
      overflow-x: hidden;
    }
    code, pre, textarea.code-area {
      font-family: 'JetBrains Mono', monospace;
    }
    /* Custom subtle scrollbar */
    ::-webkit-scrollbar {
      width: 6px;
      height: 6px;
    }
    ::-webkit-scrollbar-track {
      background: #0f131c;
    }
    ::-webkit-scrollbar-thumb {
      background: #273248;
      border-radius: 9999px;
    }
    ::-webkit-scrollbar-thumb:hover {
      background: #384766;
    }
    @keyframes pulseDot {
      0%, 100% { opacity: 1; transform: scale(1); }
      50% { opacity: 0.45; transform: scale(0.85); }
    }
    .status-dot-live {
      animation: pulseDot 1.8s infinite ease-in-out;
    }
  </style>
</head>
<body class="min-h-screen bg-surface-950 text-slate-100 antialiased selection:bg-emerald-500/30 selection:text-emerald-200">
  <div id="app" class="mx-auto flex min-h-screen w-full max-w-4xl flex-col px-3 py-4 sm:px-6 sm:py-6 gap-4">
    <!-- Top Header -->
    <header class="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-slate-800/90 bg-surface-900/95 px-4 py-3 shadow-lg shadow-black/30">
      <div class="flex items-center gap-3 min-w-0">
        <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-emerald-500/30 bg-emerald-500/10 text-emerald-400">
          <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z" />
          </svg>
        </div>
        <div class="min-w-0">
          <div class="flex items-center gap-2">
            <h1 class="truncate text-base sm:text-lg font-semibold tracking-tight text-white">
              Luau AI Builder
            </h1>
            <span class="inline-flex items-center gap-1.5 rounded-full border border-emerald-500/25 bg-emerald-500/10 px-2 py-0.5 text-[11px] font-medium text-emerald-300">
              <span class="h-1.5 w-1.5 rounded-full bg-emerald-400 status-dot-live"></span>
              Mobile Ready
            </span>
          </div>
          <p class="truncate text-xs text-slate-400">
            Генерация Luau-скриптов и упаковка payload для запуска на стороне скрипта
          </p>
        </div>
      </div>

      <!-- Mode / Engine Badge -->
      <div class="flex items-center gap-2">
        <span id="engineBadge" class="rounded-xl border border-slate-700/80 bg-surface-850 px-2.5 py-1.5 text-xs font-medium text-slate-300">
          Engine: Smart Local + Gemini
        </span>
      </div>
    </header>

    <!-- Quick Presets -->
    <section aria-label="Быстрые пресеты" class="rounded-2xl border border-slate-800/90 bg-surface-900/90 p-3.5 sm:p-4 shadow-md shadow-black/20">
      <div class="mb-2.5 flex items-center justify-between">
        <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">
          Быстрые пресеты
        </span>
        <span class="text-[11px] text-slate-500">Нажми для загрузки шаблона</span>
      </div>
      <div id="presetButtons" class="grid grid-cols-2 sm:grid-cols-4 gap-2">
        <!-- Populated by JS -->
      </div>
    </section>

    <!-- AI Prompt Builder -->
    <section aria-label="AI Генератор скриптов" class="rounded-2xl border border-slate-800/90 bg-surface-900/90 p-3.5 sm:p-4 shadow-md shadow-black/20 space-y-3">
      <div class="flex items-center justify-between gap-2">
        <label for="promptInput" class="text-xs font-semibold uppercase tracking-wider text-slate-300">
          AI Запрос (создать или доработать Luau)
        </label>
        <button
          id="toggleApiDrawerBtn"
          type="button"
          class="rounded-lg border border-slate-700/80 bg-surface-850 px-2.5 py-1 text-[11px] font-medium text-slate-300 transition hover:border-slate-600 hover:text-white active:scale-[0.98]"
        >
          Gemini Key
        </button>
      </div>

      <!-- Optional API Key Collapsible -->
      <div id="apiDrawer" class="hidden rounded-xl border border-slate-800 bg-surface-950/90 p-3 space-y-2">
        <div class="flex items-center justify-between">
          <span class="text-xs font-medium text-slate-300">Gemini API Key (опционально)</span>
          <span class="text-[11px] text-slate-500">Без ключа работает локальный AI-синтезатор</span>
        </div>
        <input
          id="apiKeyInput"
          type="password"
          placeholder="Вставь ключ AIza... или оставь пустым"
          class="w-full rounded-xl border border-slate-800 bg-surface-900 px-3 py-2 text-xs text-slate-100 placeholder-slate-500 focus:border-emerald-500/60 focus:outline-none"
        />
      </div>

      <textarea
        id="promptInput"
        rows="3"
        placeholder="Например: Сделай backtrack хитбокс с задержкой 0.2с, плавным lerp, защитой от телепортов и очисткой при перезапуске..."
        class="w-full resize-y rounded-xl border border-slate-800 bg-surface-950/90 p-3 text-sm text-slate-100 placeholder-slate-500 focus:border-emerald-500/60 focus:outline-none"
      ></textarea>

      <div class="flex flex-wrap items-center justify-between gap-2">
        <div class="flex flex-wrap items-center gap-1.5 text-[11px] text-slate-400">
          <span class="rounded-md bg-surface-850 px-2 py-1 border border-slate-800/80">Auto-cleanup</span>
          <span class="rounded-md bg-surface-850 px-2 py-1 border border-slate-800/80">Mobile-safe</span>
          <span class="rounded-md bg-surface-850 px-2 py-1 border border-slate-800/80">No leaks</span>
        </div>

        <button
          id="generateBtn"
          type="button"
          class="inline-flex w-full sm:w-auto items-center justify-center gap-2 rounded-xl bg-emerald-500 px-4 py-2.5 text-sm font-semibold text-slate-950 shadow-md shadow-emerald-500/20 transition hover:bg-emerald-400 active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-60"
        >
          <svg id="generateSpinner" class="hidden h-4 w-4 animate-spin" viewBox="0 0 24 24" fill="none">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"></path>
          </svg>
          <span id="generateBtnText">Сгенерировать Luau</span>
        </button>
      </div>
    </section>

    <!-- Code Editor / Viewer & Inject Bar -->
    <section aria-label="Редактор Luau и Инжект" class="rounded-2xl border border-slate-800/90 bg-surface-900/95 p-3.5 sm:p-4 shadow-lg shadow-black/25 space-y-3">
      <div class="flex flex-wrap items-center justify-between gap-2">
        <div class="flex items-center gap-2">
          <span class="text-xs font-semibold uppercase tracking-wider text-slate-300">
            Luau Script Editor
          </span>
          <span id="scriptMetaTag" class="rounded-md border border-slate-800 bg-surface-850 px-2 py-0.5 text-[11px] font-mono text-emerald-300">
            hitbox_backtrack.lua
          </span>
        </div>

        <div class="flex items-center gap-1.5">
          <button
            id="copyCodeBtn"
            type="button"
            class="inline-flex items-center gap-1.5 rounded-xl border border-slate-700/80 bg-surface-850 px-3 py-1.5 text-xs font-medium text-slate-200 transition hover:border-slate-600 hover:bg-surface-800 active:scale-[0.98]"
          >
            <svg class="h-3.5 w-3.5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
              <path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"></path>
            </svg>
            <span id="copyCodeText">Копировать</span>
          </button>

          <button
            id="downloadCodeBtn"
            type="button"
            class="inline-flex items-center gap-1.5 rounded-xl border border-slate-700/80 bg-surface-850 px-3 py-1.5 text-xs font-medium text-slate-200 transition hover:border-slate-600 hover:bg-surface-800 active:scale-[0.98]"
          >
            <svg class="h-3.5 w-3.5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
            </svg>
            <span>.lua</span>
          </button>
        </div>
      </div>

      <textarea
        id="codeEditor"
        rows="15"
        spellcheck="false"
        class="code-area w-full resize-y rounded-xl border border-slate-800 bg-surface-950 p-3.5 text-xs sm:text-[13px] leading-relaxed text-emerald-100/95 focus:border-emerald-500/60 focus:outline-none"
      ></textarea>

      <!-- Payload Wrapper & Inject Action -->
      <div class="rounded-xl border border-slate-800/90 bg-surface-950/80 p-3 space-y-3">
        <div class="flex flex-wrap items-center justify-between gap-2">
          <div class="flex items-center gap-2">
            <input
              id="wrapPayloadCheckbox"
              type="checkbox"
              checked
              class="h-4 w-4 rounded border-slate-700 bg-surface-850 text-emerald-500 focus:ring-emerald-500/40"
            />
            <label for="wrapPayloadCheckbox" class="text-xs font-medium text-slate-200 select-none cursor-pointer">
              Упаковать в Script-Side Payload Wrapper (авто-очистка + safe runner)
            </label>
          </div>
          <button
            id="togglePayloadPreviewBtn"
            type="button"
            class="text-[11px] font-medium text-emerald-400 hover:text-emerald-300 underline underline-offset-2"
          >
            Показать wrapper
          </button>
        </div>

        <!-- Collapsible Payload Wrapper Preview -->
        <div id="payloadPreviewBox" class="hidden space-y-1.5">
          <div class="flex items-center justify-between text-[11px] text-slate-400">
            <span>Сформированный payload для запуска на стороне скрипта</span>
            <button
              id="copyPayloadBtn"
              type="button"
              class="rounded-md border border-slate-700 bg-surface-850 px-2 py-0.5 text-[11px] text-slate-200 hover:bg-surface-800"
            >
              Копировать payload
            </button>
          </div>
          <pre id="payloadPreviewCode" class="max-h-44 overflow-auto rounded-lg border border-slate-800 bg-surface-900 p-2.5 text-[11px] leading-relaxed text-sky-200"></pre>
        </div>

        <!-- Primary Inject Button -->
        <button
          id="injectBtn"
          type="button"
          class="flex w-full items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-400 px-4 py-3 text-sm font-bold text-slate-950 shadow-lg shadow-emerald-500/20 transition hover:from-emerald-400 hover:to-teal-300 active:scale-[0.99]"
        >
          <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
          </svg>
          <span>Inject Payload (Подготовить и скопировать на сторону скрипта)</span>
        </button>
      </div>
    </section>

    <!-- Live Status Log -->
    <section aria-label="Лог статуса инжекта и генерации" class="rounded-2xl border border-slate-800/90 bg-surface-900/90 p-3.5 sm:p-4 shadow-md shadow-black/20 space-y-2.5">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2">
          <span class="text-xs font-semibold uppercase tracking-wider text-slate-300">
            Live Status Log
          </span>
          <span id="lastActionBadge" class="rounded-full bg-surface-850 px-2 py-0.5 text-[11px] text-slate-400 border border-slate-800">
            Ready
          </span>
        </div>
        <button
          id="clearLogBtn"
          type="button"
          class="text-[11px] text-slate-400 hover:text-slate-200"
        >
          Очистить
        </button>
      </div>

      <div id="statusLog" class="max-h-40 overflow-y-auto rounded-xl border border-slate-800/90 bg-surface-950 p-2.5 font-mono text-[11px] leading-relaxed space-y-1">
        <!-- Log entries inserted here -->
      </div>
    </section>
  </div>

  <!-- Toast / Inline Feedback Banner -->
  <div
    id="toastBanner"
    role="status"
    aria-live="polite"
    class="pointer-events-none fixed bottom-4 left-1/2 z-50 w-[calc(100%-1.5rem)] max-w-md -translate-x-1/2 translate-y-4 opacity-0 transition-all duration-200"
  >
    <div id="toastCard" class="flex items-center justify-between gap-3 rounded-xl border border-emerald-500/40 bg-surface-850/95 px-4 py-3 text-xs font-medium text-white shadow-2xl backdrop-blur-md">
      <span id="toastMessage">Готово</span>
      <span id="toastTag" class="rounded-md bg-emerald-500/20 px-2 py-0.5 text-[10px] font-semibold text-emerald-300">OK</span>
    </div>
  </div>

  <script>
    // =========================================================================
    // Presets & Smart Local Luau Synthesizer Templates
    // =========================================================================
    const PRESETS = [
      {
        id: 'backtrack',
        label: 'Hitbox Backtrack',
        badge: 'hitbox_backtrack.lua',
        defaultPrompt: 'Сделай мобильный backtrack хитбокс с задержкой 0.15с, авто-масштабом, плавным lerp и очисткой при перезапуске.',
        code: `local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

if _G.BacktrackCleanup then
\tpcall(_G.BacktrackCleanup)
end

local CFG = {
\tDelay = 0.15,
\tMaxKeep = 1.0,
\tAutoScaleSize = true,
\tSize = Vector3.new(4, 5, 2),
\tColor = Color3.fromRGB(0, 255, 140),
\tTransparency = 0.55,
\tLerpAlpha = 0.35,
\tTeleportThreshold = 45,
\tAlwaysOnTop = true,
}

local history = {}
local lastSample = 0
local sampleStep = 1 / 60
local hasCurrentVisual = false

local folder = Instance.new("Folder")
folder.Name = "MobileBacktrackVisual"
folder.Parent = CoreGui

local anchor = Instance.new("Part")
anchor.Name = "Anchor"
anchor.Size = CFG.Size
anchor.Anchored = true
anchor.CanCollide = false
anchor.CanQuery = false
anchor.CanTouch = false
anchor.Transparency = 1
anchor.CFrame = CFrame.new(0, -999, 0)
anchor.Parent = folder

local box = Instance.new("BoxHandleAdornment")
box.Name = "HitboxCham"
box.Adornee = anchor
box.Size = CFG.Size
box.Color3 = CFG.Color
box.Transparency = CFG.Transparency
box.AlwaysOnTop = CFG.AlwaysOnTop
box.ZIndex = 5
box.Parent = folder

local function getRoot()
\tlocal char = player.Character
\treturn char and char:FindFirstChild("HumanoidRootPart")
end

local function applyBoxSize(root)
\tlocal targetSize = CFG.Size
\tif CFG.AutoScaleSize and root and root:IsA("BasePart") then
\t\ttargetSize = root.Size * Vector3.new(2, 2.5, 1.5)
\tend
\tif box.Size ~= targetSize then
\t\tbox.Size = targetSize
\t\tanchor.Size = targetSize
\tend
end

local function getBackCFrame(targetTime)
\tlocal closest
\tlocal bestDiff = math.huge
\tfor i = #history, 1, -1 do
\t\tlocal entry = history[i]
\t\tlocal diff = math.abs(entry.t - targetTime)
\t\tif diff <= bestDiff then
\t\t\tbestDiff = diff
\t\t\tclosest = entry.cf
\t\telseif entry.t < targetTime then
\t\t\tbreak
\t\tend
\tend
\treturn closest
end

local charConn = player.CharacterAdded:Connect(function()
\ttable.clear(history)
\thasCurrentVisual = false
end)

local loopConn = RunService.Heartbeat:Connect(function()
\tlocal now = os.clock()
\tlocal root = getRoot()

\tif not root or not root:IsA("BasePart") then
\t\tanchor.CFrame = CFrame.new(0, -999, 0)
\t\thasCurrentVisual = false
\t\treturn
\tend

\tapplyBoxSize(root)

\tif now - lastSample >= sampleStep then
\t\tlastSample = now
\t\thistory[#history + 1] = { t = now, cf = root.CFrame }

\t\tlocal cutoff = now - CFG.MaxKeep
\t\twhile #history > 0 and history[1].t < cutoff do
\t\t\ttable.remove(history, 1)
\t\tend
\tend

\tlocal backCf = getBackCFrame(now - CFG.Delay)
\tif backCf then
\t\tlocal dist = (anchor.Position - backCf.Position).Magnitude
\t\tif not hasCurrentVisual or dist > CFG.TeleportThreshold or CFG.LerpAlpha >= 1 then
\t\t\tanchor.CFrame = backCf
\t\t\thasCurrentVisual = true
\t\telse
\t\t\tanchor.CFrame = anchor.CFrame:Lerp(backCf, math.clamp(CFG.LerpAlpha, 0.05, 1))
\t\tend
\tend
end)

_G.BacktrackCleanup = function()
\tif loopConn then loopConn:Disconnect() end
\tif charConn then charConn:Disconnect() end
\tif folder then folder:Destroy() end
end`,
      },
      {
        id: 'movement',
        label: 'Speed / Movement',
        badge: 'movement_helper.lua',
        defaultPrompt: 'Сделай лёгкий movement helper для мобилы: плавный WalkSpeed и JumpPower с безопасной очисткой.',
        code: `local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

if _G.MovementHelperCleanup then
\tpcall(_G.MovementHelperCleanup)
end

local CFG = {
\tEnabled = true,
\tTargetWalkSpeed = 24,
\tTargetJumpPower = 58,
\tApplyInterval = 0.15,
}

local lastApply = 0

local function applyStats()
\tif not CFG.Enabled then return end
\tlocal char = player.Character
\tlocal hum = char and char:FindFirstChildOfClass("Humanoid")
\tif not hum then return end

\tif hum.WalkSpeed ~= CFG.TargetWalkSpeed then
\t\thum.WalkSpeed = CFG.TargetWalkSpeed
\tend
\tif hum.UseJumpPower then
\t\tif hum.JumpPower ~= CFG.TargetJumpPower then
\t\t\thum.JumpPower = CFG.TargetJumpPower
\t\tend
\telse
\t\tlocal boostRatio = CFG.TargetJumpPower / 50
\t\tlocal targetHeight = 7.2 * boostRatio
\t\tif math.abs(hum.JumpHeight - targetHeight) > 0.2 then
\t\t\thum.JumpHeight = targetHeight
\t\tend
\tend
end

local conn = RunService.Heartbeat:Connect(function()
\tlocal now = os.clock()
\tif now - lastApply >= CFG.ApplyInterval then
\t\tlastApply = now
\t\tapplyStats()
\tend
end)

_G.MovementHelperCleanup = function()
\tif conn then conn:Disconnect() end
\tlocal char = player.Character
\tlocal hum = char and char:FindFirstChildOfClass("Humanoid")
\tif hum then
\t\thum.WalkSpeed = 16
\t\tif hum.UseJumpPower then
\t\t\thum.JumpPower = 50
\t\telse
\t\t\thum.JumpHeight = 7.2
\t\tend
\tend
end`,
      },
      {
        id: 'esp',
        label: 'ESP / Highlight',
        badge: 'player_highlight.lua',
        defaultPrompt: 'Сделай лёгкий Highlight ESP для игроков с авто-добавлением при респавне и полной очисткой.',
        code: `local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer

if _G.HighlightEspCleanup then
\tpcall(_G.HighlightEspCleanup)
end

local CFG = {
\tFillColor = Color3.fromRGB(56, 189, 248),
\tOutlineColor = Color3.fromRGB(224, 242, 254),
\tFillTransparency = 0.72,
\tOutlineTransparency = 0.15,
}

local container = Instance.new("Folder")
container.Name = "MobileHighlightESP"
container.Parent = CoreGui

local activeHighlights = {}
local connections = {}

local function clearPlayerHighlight(plr)
\tlocal hl = activeHighlights[plr]
\tif hl then
\t\thl:Destroy()
\t\tactiveHighlights[plr] = nil
\tend
end

local function attachCharacter(plr, char)
\tclearPlayerHighlight(plr)
\tif plr == localPlayer or not char then return end

\tlocal hl = Instance.new("Highlight")
\thl.Name = plr.Name .. "_ESP"
\thl.Adornee = char
\thl.FillColor = CFG.FillColor
\thl.OutlineColor = CFG.OutlineColor
\thl.FillTransparency = CFG.FillTransparency
\thl.OutlineTransparency = CFG.OutlineTransparency
\thl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
\thl.Parent = container

\tactiveHighlights[plr] = hl
end

local function hookPlayer(plr)
\tif plr == localPlayer then return end
\tif plr.Character then
\t\tattachCharacter(plr, plr.Character)
\tend
\tconnections[#connections + 1] = plr.CharacterAdded:Connect(function(char)
\t\tattachCharacter(plr, char)
\tend)
end

for _, plr in ipairs(Players:GetPlayers()) do
\thookPlayer(plr)
end

connections[#connections + 1] = Players.PlayerAdded:Connect(hookPlayer)
connections[#connections + 1] = Players.PlayerRemoving:Connect(function(plr)
\tclearPlayerHighlight(plr)
end)

_G.HighlightEspCleanup = function()
\tfor _, c in ipairs(connections) do
\t\tc:Disconnect()
\tend
\ttable.clear(connections)
\tfor plr in pairs(activeHighlights) do
\t\tclearPlayerHighlight(plr)
\tend
\tcontainer:Destroy()
end`,
      },
      {
        id: 'cleanup',
        label: 'Cleanup Template',
        badge: 'safe_cleanup.lua',
        defaultPrompt: 'Сделай универсальный шаблон безопасного запуска и очистки всех активных скриптов и коннектов.',
        code: `-- Universal Mobile Script Lifecycle & Cleanup Template
local _env = getgenv and getgenv() or _G

local function runCleanupRegistry()
\tif type(_env.__MobileScriptCleanups) == "table" then
\t\tfor i = #_env.__MobileScriptCleanups, 1, -1 do
\t\t\tlocal fn = _env.__MobileScriptCleanups[i]
\t\t\tif type(fn) == "function" then
\t\t\t\tpcall(fn)
\t\t\tend
\t\tend
\t\ttable.clear(_env.__MobileScriptCleanups)
\tend
end

runCleanupRegistry()
_env.__MobileScriptCleanups = {}

local activeConnections = {}
local activeInstances = {}

local function trackConnection(conn)
\ttable.insert(activeConnections, conn)
\treturn conn
end

local function trackInstance(inst)
\ttable.insert(activeInstances, inst)
\treturn inst
end

table.insert(_env.__MobileScriptCleanups, function()
\tfor _, conn in ipairs(activeConnections) do
\t\tpcall(function() conn:Disconnect() end)
\tend
\ttable.clear(activeConnections)

\tfor _, inst in ipairs(activeInstances) do
\t\tpcall(function() inst:Destroy() end)
\tend
\ttable.clear(activeInstances)
end)

-- Example tracked marker
local markerFolder = trackInstance(Instance.new("Folder"))
markerFolder.Name = "TrackedSessionFolder"
markerFolder.Parent = workspace`,
      },
    ];

    // =========================================================================
    // DOM References
    // =========================================================================
    const presetButtonsEl = document.getElementById('presetButtons');
    const promptInputEl = document.getElementById('promptInput');
    const generateBtnEl = document.getElementById('generateBtn');
    const generateBtnTextEl = document.getElementById('generateBtnText');
    const generateSpinnerEl = document.getElementById('generateSpinner');
    const codeEditorEl = document.getElementById('codeEditor');
    const scriptMetaTagEl = document.getElementById('scriptMetaTag');
    const copyCodeBtnEl = document.getElementById('copyCodeBtn');
    const copyCodeTextEl = document.getElementById('copyCodeText');
    const downloadCodeBtnEl = document.getElementById('downloadCodeBtn');
    const wrapPayloadCheckboxEl = document.getElementById('wrapPayloadCheckbox');
    const togglePayloadPreviewBtnEl = document.getElementById('togglePayloadPreviewBtn');
    const payloadPreviewBoxEl = document.getElementById('payloadPreviewBox');
    const payloadPreviewCodeEl = document.getElementById('payloadPreviewCode');
    const copyPayloadBtnEl = document.getElementById('copyPayloadBtn');
    const injectBtnEl = document.getElementById('injectBtn');
    const statusLogEl = document.getElementById('statusLog');
    const clearLogBtnEl = document.getElementById('clearLogBtn');
    const lastActionBadgeEl = document.getElementById('lastActionBadge');
    const toggleApiDrawerBtnEl = document.getElementById('toggleApiDrawerBtn');
    const apiDrawerEl = document.getElementById('apiDrawer');
    const apiKeyInputEl = document.getElementById('apiKeyInput');
    const engineBadgeEl = document.getElementById('engineBadge');
    const toastBannerEl = document.getElementById('toastBanner');
    const toastCardEl = document.getElementById('toastCard');
    const toastMessageEl = document.getElementById('toastMessage');
    const toastTagEl = document.getElementById('toastTag');

    let activePresetId = PRESETS[0].id;
    let toastTimeout = null;

    // =========================================================================
    // Logging & Toast Helpers
    // =========================================================================
    function formatTime() {
      const now = new Date();
      return now.toTimeString().split(' ')[0];
    }

    function appendLog(message, level = 'info') {
      const colors = {
        info: 'text-slate-300',
        success: 'text-emerald-300',
        warn: 'text-amber-300',
        error: 'text-rose-300',
      };
      const row = document.createElement('div');
      row.className = `${colors[level] || colors.info} flex items-start gap-2`;
      row.innerHTML = `<span class="text-slate-500 shrink-0">[${formatTime()}]</span><span class="break-words">${escapeHtml(message)}</span>`;
      statusLogEl.appendChild(row);
      statusLogEl.scrollTop = statusLogEl.scrollHeight;
    }

    function setLastAction(text) {
      lastActionBadgeEl.textContent = text;
    }

    function showToast(message, tag = 'OK', variant = 'success') {
      toastMessageEl.textContent = message;
      toastTagEl.textContent = tag;

      if (variant === 'warn') {
        toastCardEl.className = 'flex items-center justify-between gap-3 rounded-xl border border-amber-500/40 bg-surface-850/95 px-4 py-3 text-xs font-medium text-white shadow-2xl backdrop-blur-md';
        toastTagEl.className = 'rounded-md bg-amber-500/20 px-2 py-0.5 text-[10px] font-semibold text-amber-300';
      } else {
        toastCardEl.className = 'flex items-center justify-between gap-3 rounded-xl border border-emerald-500/40 bg-surface-850/95 px-4 py-3 text-xs font-medium text-white shadow-2xl backdrop-blur-md';
        toastTagEl.className = 'rounded-md bg-emerald-500/20 px-2 py-0.5 text-[10px] font-semibold text-emerald-300';
      }

      toastBannerEl.classList.remove('pointer-events-none', 'opacity-0', 'translate-y-4');
      toastBannerEl.classList.add('opacity-100', 'translate-y-0');

      if (toastTimeout) clearTimeout(toastTimeout);
      toastTimeout = setTimeout(() => {
        toastBannerEl.classList.add('pointer-events-none', 'opacity-0', 'translate-y-4');
        toastBannerEl.classList.remove('opacity-100', 'translate-y-0');
      }, 2600);
    }

    function escapeHtml(str) {
      return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
    }

    // =========================================================================
    // Payload Packaging (Script-Side Runner)
    // =========================================================================
    function buildScriptSidePayload(rawCode, useWrapper) {
      const cleanCode = rawCode.trim();
      if (!useWrapper) {
        return cleanCode;
      }

      const payloadId = `PAYLOAD_${Date.now().toString(36).toUpperCase()}`;
      return [
        `-- Script-Side Payload Container (${payloadId})`,
        `local _env = (getgenv and getgenv()) or _G`,
        `if type(_env.__ActiveScriptPayloadCleanup) == "function" then`,
        `\tpcall(_env.__ActiveScriptPayloadCleanup)`,
        `end`,
        ``,
        `local function __executeScriptPayload()`,
        cleanCode.split('\n').map((line) => `\t${line}`).join('\n'),
        `end`,
        ``,
        `local ok, err = pcall(__executeScriptPayload)`,
        `if not ok then`,
        `\twarn("[Payload Error] " .. tostring(err))`,
        `end`,
        ``,
        `_env.__ActiveScriptPayloadCleanup = function()`,
        `\tif type(_env.BacktrackCleanup) == "function" then pcall(_env.BacktrackCleanup) end`,
        `\tif type(_env.MovementHelperCleanup) == "function" then pcall(_env.MovementHelperCleanup) end`,
        `\tif type(_env.HighlightEspCleanup) == "function" then pcall(_env.HighlightEspCleanup) end`,
        `end`,
      ].join('\n');
    }

    function refreshPayloadPreview() {
      const payload = buildScriptSidePayload(codeEditorEl.value, wrapPayloadCheckboxEl.checked);
      payloadPreviewCodeEl.textContent = payload;
    }

    // =========================================================================
    // Clipboard & File Export Helpers
    // =========================================================================
    function copyToClipboard(text) {
      if (navigator.clipboard && window.isSecureContext) {
        return navigator.clipboard.writeText(text).catch(() => fallbackCopy(text));
      }
      return Promise.resolve(fallbackCopy(text));
    }

    function fallbackCopy(text) {
      const ta = document.createElement('textarea');
      ta.value = text;
      ta.setAttribute('readonly', '');
      ta.style.position = 'fixed';
      ta.style.left = '-9999px';
      document.body.appendChild(ta);
      ta.select();
      ta.setSelectionRange(0, ta.value.length);
      try {
        document.execCommand('copy');
        return true;
      } catch (e) {
        return false;
      } finally {
        document.body.removeChild(ta);
      }
    }

    function downloadLuauFile(filename, content) {
      const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = filename.endsWith('.lua') ? filename : `${filename}.lua`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      setTimeout(() => URL.revokeObjectURL(url), 1000);
    }

    // =========================================================================
    // Smart Local Luau Synthesizer + Gemini API Integration
    // =========================================================================
    function synthesizeLocalLuau(promptText, currentCode) {
      const p = promptText.toLowerCase();

      // Extract delay if mentioned (e.g., 0.2, 0.25, 0.3)
      const delayMatch = p.match(/(\d+(?:[.,]\d+)?)\s*(?:с|сек|s|sec)/i);
      const parsedDelay = delayMatch ? Math.min(Math.max(parseFloat(delayMatch[1].replace(',', '.')), 0.02), 1.0) : 0.15;

      // Extract speed if mentioned
      const speedMatch = p.match(/(?:speed|скорост[ьи]?|walkspeed)\s*(\d{1,3})/i);
      const parsedSpeed = speedMatch ? Math.min(Math.max(parseInt(speedMatch[1], 10), 8), 150) : 28;

      if (p.includes('backtrack') || p.includes('бектрек') || p.includes('хитбокс') || p.includes('hitbox')) {
        const useLerp = !p.includes('без lerp') && !p.includes('snap');
        const lerpVal = useLerp ? 0.35 : 1.0;
        const colorLine = p.includes('красн') || p.includes('red')
          ? 'Color3.fromRGB(255, 70, 95)'
          : p.includes('син') || p.includes('blue')
            ? 'Color3.fromRGB(56, 189, 248)'
            : 'Color3.fromRGB(0, 255, 140)';

        scriptMetaTagEl.textContent = 'ai_backtrack_custom.lua';
        return `-- Generated by Luau AI Builder (Mobile Safe)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
if _G.BacktrackCleanup then pcall(_G.BacktrackCleanup) end

local CFG = {
\tDelay = ${parsedDelay},
\tMaxKeep = ${Math.max(1.0, +(parsedDelay * 5).toFixed(2))},
\tAutoScaleSize = true,
\tSize = Vector3.new(4, 5, 2),
\tColor = ${colorLine},
\tTransparency = 0.55,
\tLerpAlpha = ${lerpVal},
\tTeleportThreshold = 45,
\tAlwaysOnTop = true,
}

local history = {}
local lastSample = 0
local sampleStep = 1 / 60
local hasVisual = false

local folder = Instance.new("Folder")
folder.Name = "AI_Backtrack_Folder"
folder.Parent = CoreGui

local anchor = Instance.new("Part")
anchor.Name = "BacktrackAnchor"
anchor.Size = CFG.Size
anchor.Anchored = true
anchor.CanCollide = false
anchor.CanQuery = false
anchor.CanTouch = false
anchor.Transparency = 1
anchor.CFrame = CFrame.new(0, -999, 0)
anchor.Parent = folder

local box = Instance.new("BoxHandleAdornment")
box.Adornee = anchor
box.Size = CFG.Size
box.Color3 = CFG.Color
box.Transparency = CFG.Transparency
box.AlwaysOnTop = CFG.AlwaysOnTop
box.ZIndex = 5
box.Parent = folder

local function getRoot()
\tlocal char = player.Character
\treturn char and char:FindFirstChild("HumanoidRootPart")
end

local function getSampleAt(targetTime)
\tlocal bestCf
\tlocal bestDiff = math.huge
\tfor i = #history, 1, -1 do
\t\tlocal item = history[i]
\t\tlocal diff = math.abs(item.t - targetTime)
\t\tif diff <= bestDiff then
\t\t\tbestDiff = diff
\t\t\tbestCf = item.cf
\t\telseif item.t < targetTime then
\t\t\tbreak
\t\tend
\tend
\treturn bestCf
end

local charConn = player.CharacterAdded:Connect(function()
\ttable.clear(history)
\thasVisual = false
end)

local loopConn = RunService.Heartbeat:Connect(function()
\tlocal now = os.clock()
\tlocal root = getRoot()
\tif not root or not root:IsA("BasePart") then
\t\tanchor.CFrame = CFrame.new(0, -999, 0)
\t\thasVisual = false
\t\treturn
\tend

\tif CFG.AutoScaleSize then
\t\tlocal sz = root.Size * Vector3.new(2, 2.5, 1.5)
\t\tbox.Size = sz
\t\tanchor.Size = sz
\tend

\tif now - lastSample >= sampleStep then
\t\tlastSample = now
\t\thistory[#history + 1] = { t = now, cf = root.CFrame }
\t\tlocal cutoff = now - CFG.MaxKeep
\t\twhile #history > 0 and history[1].t < cutoff do
\t\t\ttable.remove(history, 1)
\t\tend
\tend

\tlocal targetCf = getSampleAt(now - CFG.Delay)
\tif targetCf then
\t\tlocal dist = (anchor.Position - targetCf.Position).Magnitude
\t\tif not hasVisual or dist > CFG.TeleportThreshold or CFG.LerpAlpha >= 1 then
\t\t\tanchor.CFrame = targetCf
\t\t\thasVisual = true
\t\telse
\t\t\tanchor.CFrame = anchor.CFrame:Lerp(targetCf, math.clamp(CFG.LerpAlpha, 0.05, 1))
\t\tend
\tend
end)

_G.BacktrackCleanup = function()
\tif loopConn then loopConn:Disconnect() end
\tif charConn then charConn:Disconnect() end
\tif folder then folder:Destroy() end
end`;
      }

      if (p.includes('speed') || p.includes('скорост') || p.includes('jump') || p.includes('прыж')) {
        scriptMetaTagEl.textContent = 'ai_speed_mod.lua';
        return `-- Generated by Luau AI Builder (Movement Controller)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if _G.MovementHelperCleanup then pcall(_G.MovementHelperCleanup) end

local CFG = {
\tWalkSpeed = ${parsedSpeed},
\tJumpPower = 56,
\tStep = 0.15,
}

local lastTick = 0
local conn = RunService.Heartbeat:Connect(function()
\tlocal now = os.clock()
\tif now - lastTick < CFG.Step then return end
\tlastTick = now

\tlocal hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
\tif hum then
\t\thum.WalkSpeed = CFG.WalkSpeed
\t\tif hum.UseJumpPower then
\t\t\thum.JumpPower = CFG.JumpPower
\t\tend
\tend
end)

_G.MovementHelperCleanup = function()
\tif conn then conn:Disconnect() end
\tlocal hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
\tif hum then hum.WalkSpeed = 16 end
end`;
      }

      // General modification / fallback synthesis around current editor code
      scriptMetaTagEl.textContent = 'ai_custom_luau.lua';
      const commentHeader = `-- AI Prompt Note: ${promptText.replace(/\n+/g, ' ').slice(0, 120)}`;
      if (currentCode && currentCode.trim().length > 20) {
        return `${commentHeader}\n${currentCode.trim()}`;
      }
      return `${commentHeader}\n${PRESETS[0].code}`;
    }

    async function callGeminiWithBackoff(promptText, currentCode, apiKey, maxRetries = 3) {
      const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=${encodeURIComponent(apiKey)}`;
      const systemInstruction = [
        "You are an expert Roblox Luau scripter for mobile executors.",
        "Return ONLY raw runnable Luau code (no markdown fences, no commentary outside code).",
        "Keep scripts lightweight, mobile-friendly, leak-free, and include cleanup logic when appropriate."
      ].join(" ");

      const userPrompt = [
        `User request: ${promptText}`,
        `Current editor Luau code:\n${currentCode}`
      ].join("\n\n");

      const payload = {
        contents: [{ parts: [{ text: userPrompt }] }],
        systemInstruction: { parts: [{ text: systemInstruction }] },
      };

      let delayMs = 1000;
      for (let attempt = 0; attempt <= maxRetries; attempt++) {
        try {
          const res = await fetch(apiUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload),
          });

          if (!res.ok) {
            if ((res.status === 429 || res.status >= 500) && attempt < maxRetries) {
              await new Promise((r) => setTimeout(r, delayMs));
              delayMs *= 2;
              continue;
            }
            throw new Error(`HTTP ${res.status}`);
          }

          const data = await res.json();
          const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
          if (!text) {
            throw new Error('Empty response from Gemini');
          }

          // Strip accidental markdown code fences if present
          return text
            .replace(/^```(?:luau|lua)?\s*/i, '')
            .replace(/\s*```$/i, '')
            .trim();
        } catch (err) {
          if (attempt === maxRetries) {
            throw err;
          }
          await new Promise((r) => setTimeout(r, delayMs));
          delayMs *= 2;
        }
      }
    }

    // =========================================================================
    // UI Initialization & Event Listeners
    // =========================================================================
    function renderPresets() {
      presetButtonsEl.innerHTML = '';
      PRESETS.forEach((preset) => {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.dataset.presetId = preset.id;
        btn.className = 'rounded-xl border px-3 py-2.5 text-left text-xs font-medium transition active:scale-[0.98]';
        updatePresetButtonStyle(btn, preset.id === activePresetId);

        btn.innerHTML = `
          <div class="font-semibold text-slate-100 truncate">${escapeHtml(preset.label)}</div>
          <div class="text-[10px] font-mono text-slate-400 truncate mt-0.5">${escapeHtml(preset.badge)}</div>
        `;

        btn.addEventListener('click', () => {
          activePresetId = preset.id;
          codeEditorEl.value = preset.code;
          promptInputEl.value = preset.defaultPrompt;
          scriptMetaTagEl.textContent = preset.badge;
          refreshPayloadPreview();
          document.querySelectorAll('#presetButtons button').forEach((el) => {
            updatePresetButtonStyle(el, el.dataset.presetId === activePresetId);
          });
          setLastAction(`Preset: ${preset.label}`);
          appendLog(`Загружен пресет "${preset.label}" (${preset.badge}).`, 'info');
          showToast(`Загружен пресет: ${preset.label}`, 'PRESET');
        });

        presetButtonsEl.appendChild(btn);
      });
    }

    function updatePresetButtonStyle(btn, isActive) {
      if (isActive) {
        btn.className = 'rounded-xl border border-emerald-500/60 bg-emerald-500/15 px-3 py-2.5 text-left text-xs font-medium transition active:scale-[0.98] shadow-sm shadow-emerald-500/10';
      } else {
        btn.className = 'rounded-xl border border-slate-800 bg-surface-850/90 px-3 py-2.5 text-left text-xs font-medium transition hover:border-slate-700 hover:bg-surface-800 active:scale-[0.98]';
      }
    }

    toggleApiDrawerBtnEl.addEventListener('click', () => {
      apiDrawerEl.classList.toggle('hidden');
    });

    apiKeyInputEl.addEventListener('input', () => {
      const hasKey = apiKeyInputEl.value.trim().length > 0;
      engineBadgeEl.textContent = hasKey ? 'Engine: Gemini AI + Fallback' : 'Engine: Smart Local AI';
    });

    generateBtnEl.addEventListener('click', async () => {
      const promptText = promptInputEl.value.trim() || 'Сделай чистый мобильный Luau-скрипт с авто-очисткой.';
      generateBtnEl.disabled = true;
      generateSpinnerEl.classList.remove('hidden');
      generateBtnTextEl.textContent = 'Генерация...';
      setLastAction('Generating');

      const apiKey = apiKeyInputEl.value.trim();

      try {
        let generatedCode = '';
        if (apiKey) {
          appendLog('Отправляю запрос в Gemini API...', 'info');
          generatedCode = await callGeminiWithBackoff(promptText, codeEditorEl.value, apiKey);
          scriptMetaTagEl.textContent = 'gemini_luau_script.lua';
          appendLog('Gemini вернул обновлённый Luau-код.', 'success');
          showToast('Luau сгенерирован через Gemini', 'AI OK');
        } else {
          generatedCode = synthesizeLocalLuau(promptText, codeEditorEl.value);
          appendLog('Синтезирован локальный Luau-скрипт по твоему запросу.', 'success');
          showToast('Luau скрипт синтезирован', 'LOCAL AI');
        }

        codeEditorEl.value = generatedCode;
        refreshPayloadPreview();
        setLastAction('Generated');
      } catch (err) {
        const fallbackCode = synthesizeLocalLuau(promptText, codeEditorEl.value);
        codeEditorEl.value = fallbackCode;
        refreshPayloadPreview();
        setLastAction('Fallback');
        appendLog(`Gemini недоступен (${err.message}), применён локальный синтезатор.`, 'warn');
        showToast('Использован локальный синтезатор', 'FALLBACK', 'warn');
      } finally {
        generateBtnEl.disabled = false;
        generateSpinnerEl.classList.add('hidden');
        generateBtnTextEl.textContent = 'Сгенерировать Luau';
      }
    });

    codeEditorEl.addEventListener('input', () => {
      refreshPayloadPreview();
    });

    wrapPayloadCheckboxEl.addEventListener('change', () => {
      refreshPayloadPreview();
      appendLog(
        wrapPayloadCheckboxEl.checked
          ? 'Включена упаковка в Script-Side Payload Wrapper.'
          : 'Отключена обёртка: будет использоваться чистый код из редактора.',
        'info'
      );
    });

    togglePayloadPreviewBtnEl.addEventListener('click', () => {
      refreshPayloadPreview();
      const isHidden = payloadPreviewBoxEl.classList.contains('hidden');
      payloadPreviewBoxEl.classList.toggle('hidden');
      togglePayloadPreviewBtnEl.textContent = isHidden ? 'Скрыть wrapper' : 'Показать wrapper';
    });

    copyCodeBtnEl.addEventListener('click', async () => {
      const ok = await copyToClipboard(codeEditorEl.value);
      if (ok) {
        copyCodeTextEl.textContent = 'Скопировано';
        appendLog('Исходный Luau-код скопирован в буфер обмена.', 'success');
        showToast('Luau-код скопирован', 'COPIED');
        setTimeout(() => {
          copyCodeTextEl.textContent = 'Копировать';
        }, 1600);
      } else {
        appendLog('Не удалось скопировать код автоматически.', 'warn');
        showToast('Выдели текст вручную для копирования', 'MANUAL', 'warn');
      }
    });

    copyPayloadBtnEl.addEventListener('click', async () => {
      const payload = buildScriptSidePayload(codeEditorEl.value, wrapPayloadCheckboxEl.checked);
      const ok = await copyToClipboard(payload);
      if (ok) {
        appendLog('Payload wrapper скопирован в буфер обмена.', 'success');
        showToast('Payload скопирован', 'PAYLOAD');
      } else {
        appendLog('Ошибка копирования payload.', 'warn');
      }
    });

    downloadCodeBtnEl.addEventListener('click', () => {
      const fileName = scriptMetaTagEl.textContent.trim() || 'luau_script.lua';
      downloadLuauFile(fileName, codeEditorEl.value);
      appendLog(`Скачан файл ${fileName}.`, 'success');
      showToast(`Скачан ${fileName}`, 'SAVED');
    });

    injectBtnEl.addEventListener('click', async () => {
      const useWrapper = wrapPayloadCheckboxEl.checked;
      const finalPayload = buildScriptSidePayload(codeEditorEl.value, useWrapper);
      const byteLength = new Blob([finalPayload]).size;
      const lineCount = finalPayload.split('\n').length;

      const copied = await copyToClipboard(finalPayload);
      setLastAction('Injected');

      if (copied) {
        appendLog(
          `Payload подготовлен и скопирован (${lineCount} строк, ${byteLength} B, wrapper=${useWrapper ? 'ON' : 'OFF'}). Готов к запуску на стороне скрипта.`,
          'success'
        );
        showToast('Payload готов и скопирован для запуска', 'INJECTED');
      } else {
        appendLog(
          `Payload собран (${lineCount} строк, ${byteLength} B), но буфер обмена заблокирован — открой preview и скопируй вручную.`,
          'warn'
        );
        payloadPreviewBoxEl.classList.remove('hidden');
        togglePayloadPreviewBtnEl.textContent = 'Скрыть wrapper';
        refreshPayloadPreview();
        showToast('Payload собран (проверь preview)', 'READY', 'warn');
      }
    });

    clearLogBtnEl.addEventListener('click', () => {
      statusLogEl.innerHTML = '';
      appendLog('Лог очищен.', 'info');
    });

    // Boot initialization
    (function init() {
      const initialPreset = PRESETS[0];
      codeEditorEl.value = initialPreset.code;
      promptInputEl.value = initialPreset.defaultPrompt;
      scriptMetaTagEl.textContent = initialPreset.badge;
      renderPresets();
      refreshPayloadPreview();
      appendLog('Luau AI Builder инициализирован. Выбери пресет или опиши фичу.', 'success');
    })();
  </script>
</body>
</html>

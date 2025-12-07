# Laravel Integration Guide

**FOR CLAUDE CODE:** When a user asks you to integrate Laravel components from this showcase repository into their project, follow these instructions carefully.

---

## Overview

This repository is a **Laravel-specific reference library** of Claude Code infrastructure components. Users will ask you to help integrate specific pieces into their Laravel projects. Your role is to:

1. **Ask clarifying questions** about their Laravel project structure
2. **Copy the appropriate Laravel components**
3. **Customize configurations** for their Laravel setup
4. **Verify the integration** works correctly

**Key Principle:** ALWAYS ask before assuming Laravel project structure. What works for one Laravel project won't work for another.

---

## Laravel Tech Stack Compatibility Check

**CRITICAL:** Before integrating a skill, verify the user's Laravel tech stack matches the skill requirements.

### Laravel Backend Skills

**laravel-dev-guidelines requires:**
- Laravel 11+ (recommended) or Laravel 10+
- PHP 8.2+ (for modern features)
- Composer for dependency management
- Artisan command line

**Before integrating, ask:**
"What version of Laravel are you using?"

**If NO (Laravel < 10):**
```
The laravel-dev-guidelines skill is designed for Laravel 11+ with modern PHP 8.2+ features. I can:
1. Help you create similar guidelines adapted for your Laravel version
2. Extract the framework-agnostic patterns (layered architecture, etc.)
3. Skip this skill if not relevant

Which would you prefer?
```

### Laravel Frontend Skills

**laravel-frontend-guidelines requires:**
- Laravel with Blade templates
- Vite for asset compilation (Laravel 9+)
- Optional: Livewire, Alpine.js
- Optional: Bootstrap 5 or Tailwind CSS

**Before integrating, ask:**
"Do you use Blade templates with Vite? Any CSS framework?"

**If NO (different frontend):**
```
The laravel-frontend-guidelines skill is designed for Blade + Vite. I can:
1. Help you create similar guidelines adapted for [their frontend stack]
2. Extract the organization patterns that transfer
3. Skip this skill and use the React skill if you have a separate frontend

Which would you prefer?
```

### Skills That Are Framework-Agnostic

These work for ANY Laravel setup:
- ✅ **skill-developer** - Meta-skill, no Laravel requirements
- ✅ **error-tracking** - Sentry works with Laravel (install via Composer)
- ✅ **route-tester** - Works with Laravel's authentication system

---

## General Integration Pattern

When user says: **"Add [component] to my Laravel project"**

1. Identify component type (skill/hook/agent/command)
2. **CHECK LARAVEL COMPATIBILITY** (for Laravel-specific skills)
3. Ask about their Laravel project structure
4. Copy files OR adapt for their Laravel setup
5. Customize for their Laravel configuration
6. Verify integration
7. Provide next steps

---

## Integrating Laravel Skills

### Step-by-Step Process

**When user requests a Laravel skill** (e.g., "add laravel-dev-guidelines"):

#### 1. Understand Their Laravel Project

**ASK THESE QUESTIONS:**
- "What version of Laravel are you using?"
- "What's your project structure? Standard Laravel or custom?"
- "Do you use the default Laravel directory structure?"
- "What databases and caching are you using?"

#### 2. Copy the Laravel Skill

```bash
cp -r /path/to/showcase/.claude/skills/[skill-name] \
      $LARAVEL_PROJECT_DIR/.claude/skills/
```

#### 3. Handle skill-rules.json

**Check if it exists:**
```bash
ls $LARAVEL_PROJECT_DIR/.claude/skills/skill-rules.json
```

**If NO (doesn't exist):**
- Copy the template from showcase
- Remove skills user doesn't want
- Customize for their Laravel project

**If YES (exists):**
- Read their current skill-rules.json
- Add the new Laravel skill entry
- Merge carefully to avoid breaking existing skills

#### 4. Customize Laravel Path Patterns

**CRITICAL:** Update `pathPatterns` in skill-rules.json to match THEIR Laravel structure:

**Example - Standard Laravel:**
```json
{
  "laravel-dev-guidelines": {
    "fileTriggers": {
      "pathPatterns": [
        "app/**/*.php",
        "database/migrations/**/*.php",
        "database/factories/**/*.php",
        "database/seeders/**/*.php",
        "routes/**/*.php",
        "config/**/*.php",
        "tests/**/*.php"
      ]
    }
  }
}
```

**Example - Laravel Package:**
```json
{
  "laravel-dev-guidelines": {
    "fileTriggers": {
      "pathPatterns": [
        "src/**/*.php",
        "resources/views/**/*.php",
        "database/migrations/**/*.php",
        "config/**/*.php"
      ]
    }
  }
}
```

**Example - Laravel with Custom Structure:**
```json
{
  "laravel-dev-guidelines": {
    "fileTriggers": {
      "pathPatterns": [
        "modules/*/src/**/*.php",
        "app/Http/**/*.php",
        "app/Models/**/*.php",
        "app/Services/**/*.php"
      ]
    }
  }
}
```

**Safe Generic Laravel Patterns** (when unsure):
```json
{
  "pathPatterns": [
    "**/*.php",               // All PHP files
    "routes/**/*.php",        // Laravel routes
    "database/**/*.php",      // Laravel database files
    "config/**/*.php"         // Laravel config files
  ]
}
```

#### 5. Verify Integration

```bash
# Check Laravel skill was copied
ls -la $LARAVEL_PROJECT_DIR/.claude/skills/[skill-name]

# Validate skill-rules.json syntax
cat $LARAVEL_PROJECT_DIR/.claude/skills/skill-rules.json | jq .
```

**Tell user:** "Try editing a Laravel file in app/Http/Controllers/ and the skill should activate."

---

### Laravel Skill-Specific Notes

#### laravel-dev-guidelines
- **Laravel Requirements:** Laravel 10+ (11+ recommended)
- **Ask:** "What version of Laravel? Any custom directory structure?"
- **Customize:** pathPatterns for their Laravel structure
- **Example paths:** `app/`, `src/`, `modules/`, `packages/`
- **Adaptation tip:** Architecture patterns transfer to any Laravel version

#### laravel-frontend-guidelines
- **Laravel Requirements:** Blade + Vite (Laravel 9+)
- **Ask:** "Do you use Blade with Vite? Livewire or Alpine.js?"
- **If different:** Offer to create adapted version (Inertia.js, API-only)
- **Customize:** pathPatterns + asset management setup
- **Example paths:** `resources/views/`, `resources/css/`, `resources/js/`
- **Adaptation tip:** Blade component patterns transfer, asset setup varies

#### route-tester
- **Laravel Requirements:** Any Laravel authentication system
- **Ask:** "What authentication system do you use? Sanctum, Passport, or custom?"
- **If NO auth:** "This skill is for authenticated routes. Want me to adapt it or skip?"
- **Customize:** Test files location and auth patterns
- **Works with:** Any Laravel authentication system

#### error-tracking
- **Laravel Requirements:** Sentry Laravel package
- **Ask:** "Do you have Sentry installed? composer require sentry/sentry-laravel"
- **If NO Sentry:** "Want me to help set up Sentry or adapt for [their error tracking]?"
- **Customize:** pathPatterns
- **Adaptation tip:** Error tracking philosophy transfers to Bugsnag, Rollbar, etc.

---

## Adapting Laravel Skills for Different Setups

When user's Laravel setup differs from skill requirements, you have options:

### Option 1: Adapt Existing Laravel Skill (Recommended)

**When to use:** User wants similar guidelines but for different Laravel configuration

**Process:**
1. **Copy the Laravel skill as starting point:**
   ```bash
   cp -r showcase/.claude/skills/laravel-dev-guidelines \
         $LARAVEL_PROJECT_DIR/.claude/skills/laravel-custom-guidelines
   ```

2. **Identify what needs changing:**
   - Laravel version-specific features
   - Custom directory structures
   - Different authentication systems
   - Alternative caching/database setups

3. **Keep what transfers:**
   - MVC architecture principles
   - Eloquent best practices
   - Service layer patterns
   - Testing strategies

4. **Replace examples systematically:**
   - Ask user for their specific patterns
   - Update code examples to match their Laravel setup
   - Keep the overall structure and sections

5. **Update skill name and triggers:**
   - Rename skill appropriately
   - Update skill-rules.json triggers for their setup
   - Test activation

**Example - Adapting for Laravel Package Development:**
```
I'll create laravel-package-guidelines based on the laravel-dev-guidelines skill:
- Replace app/ directory with src/ package structure
- Replace standard routes with package service providers
- Replace migrations with package migrations
- Keep: Service patterns, testing, architecture

This will take a few minutes. Sound good?
```

### Option 2: Extract Framework-Agnostic Patterns

**When to use:** Laravel versions are very different or package development

**Process:**
1. Read through the existing Laravel skill
2. Identify framework-agnostic patterns:
   - Layered architecture (Controllers → Services → Repositories)
   - Separation of concerns principles
   - Error handling philosophy
   - Testing strategies
   - Performance optimization principles

3. Create new skill with just those patterns
4. User can add Laravel-specific examples later

**Example:**
```
The laravel-dev-guidelines uses Laravel 11, but the layered architecture
(Controllers → Services → Repositories) works for Laravel 9 too.

I can create a skill with:
- Layered architecture pattern
- Separation of concerns principles
- Error handling best practices
- Testing strategies

Then you can add Laravel 9-specific examples as you establish patterns.
```

### Option 3: Use as Reference Only

**When to use:** Too different to adapt, but user wants inspiration

**Process:**
1. User browses the existing Laravel skill
2. You help create a new skill from scratch
3. Use existing skill's structure as a template
4. Follow modular pattern (main + resource files)

### What Usually Transfers Across Laravel Setups

**Architecture & Organization:**
- ✅ Layered architecture (Controllers/Services/Repositories pattern)
- ✅ Separation of concerns
- ✅ File organization strategies
- ✅ Progressive disclosure (main + resource files)
- ✅ Repository pattern for data access

**Development Practices:**
- ✅ Error handling philosophy
- ✅ Input validation importance
- ✅ Testing strategies
- ✅ Performance optimization principles
- ✅ Laravel coding standards

**Laravel-Specific Code:**
- ❌ Laravel 11 features → Don't transfer to Laravel 9
- ❌ Specific middleware implementations → Different per version
- ❌ Route model binding syntax → Varies by version
- ❌ Artisan commands → Framework-specific

### When to Recommend Adaptation vs Skipping

**Recommend adaptation if:**
- User wants similar guidelines for their Laravel setup
- Core patterns apply (layered architecture, etc.)
- User has time to help with Laravel-specific examples

**Recommend skipping if:**
- Laravel versions are very different (pre-8.0)
- User doesn't need Laravel-specific patterns
- Would take too long to adapt
- User prefers creating from scratch

---

## Integrating Laravel Agents

**Laravel Agents are STANDALONE** - easiest to integrate!

### Standard Laravel Agent Integration

```bash
# Copy the Laravel agent file
cp showcase/.claude/agents/laravel-[agent-name].md \
      $LARAVEL_PROJECT_DIR/.claude/agents/
```

**That's it!** Laravel agents work immediately, no configuration needed.

### Check for Laravel-Specific Paths

Some agents may reference paths. **Before copying, read the agent file and check for:**

- `~/git/old-project/` → Should be `$LARAVEL_PROJECT_DIR` or `.`
- Hardcoded Laravel paths → Ask user where their Laravel project is
- Artisan command references → Ensure they match user's setup

**If found, update them:**
```bash
sed -i 's|~/git/old-laravel-project/|./|g' $LARAVEL_PROJECT_DIR/.claude/agents/[agent].md
```

### Laravel Agent-Specific Notes

**laravel-route-debugger / laravel-error-fixer:**
- Require Laravel installation
- Ask: "Do you have Laravel installed via Composer?"
- If NO: "These agents are for Laravel projects. Skip them or want me to help set up Laravel?"

**All other agents:**
- Copy as-is, they're fully generic
- Frontend agents work with Laravel + React/Vue setups
- Backend agents work with any backend, including Laravel

---

## Integrating Laravel Commands

```bash
# Copy Laravel command file
cp showcase/.claude/commands/laravel-[command].md \
      $LARAVEL_PROJECT_DIR/.claude/commands/
```

### Customize Laravel Paths

Commands may reference Laravel project paths. **Check and update:**

**laravel-docs and laravel-route-research:**
- Look for Laravel directory references
- Ask: "Where is your Laravel project located?"
- Update paths in the command files

**General route-research command:**
- May reference API structure
- Ask about their Laravel API organization

---

## Common Patterns & Best Practices

### Pattern: Asking About Laravel Project Structure

**DON'T assume:**
- ❌ "I'll add this for your app/Http/Controllers/"
- ❌ "Configuring for your routes/api.php"

**DO ask:**
- ✅ "What's your Laravel project structure? Standard Laravel or custom?"
- ✅ "Where are your controllers located?"
- ✅ "Do you use the default Laravel directory structure?"

### Pattern: Customizing skill-rules.json for Laravel

**User has standard Laravel:**
```json
{
  "pathPatterns": [
    "app/**/*.php",
    "routes/**/*.php",
    "database/**/*.php",
    "config/**/*.php"
  ]
}
```

**User has Laravel package:**
```json
{
  "pathPatterns": [
    "src/**/*.php",
    "resources/views/**/*.php",
    "config/**/*.php"
  ]
}
```

**User has custom Laravel structure:**
```json
{
  "pathPatterns": [
    "modules/*/src/**/*.php",
    "packages/*/src/**/*.php"
  ]
}
```

### Pattern: Laravel settings.json Integration

**NEVER copy the showcase settings.json directly!**

Instead, **extract and merge** the sections they need:

1. Read their existing settings.json
2. Add the Laravel hook configurations they want
3. Preserve their existing config

**Example merge:**
```json
{
  // ... their existing config ...
  "hooks": {
    // ... their existing hooks ...
    "UserPromptSubmit": [  // ← Add this section
      {
        "hooks": [
          {
            "type": "command",
            "command": "$LARAVEL_PROJECT_DIR/.claude/hooks/skill-activation-prompt.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Verification Checklist for Laravel

After integration, **verify these items:**

```bash
# 1. Laravel hooks are executable
ls -la $LARAVEL_PROJECT_DIR/.claude/hooks/*.sh
# Should show: -rwxr-xr-x

# 2. skill-rules.json is valid JSON
cat $LARAVEL_PROJECT_DIR/.claude/skills/skill-rules.json | jq .
# Should parse without errors

# 3. Hook dependencies installed (if needed)
ls $LARAVEL_PROJECT_DIR/.claude/hooks/node_modules/
# Should show packages if package.json exists

# 4. settings.json is valid JSON
cat $LARAVEL_PROJECT_DIR/.claude/settings.json | jq .
# Should parse without errors

# 5. Laravel project is working
cd $LARAVEL_PROJECT_DIR && php artisan --version
# Should show Laravel version
```

**Then ask user to test:**
- "Try editing a Laravel file in app/ and the skill should activate"
- "Ask me a question about Laravel development - I should suggest the Laravel skill"

---

## Common Mistakes to Avoid

### ❌ DON'T: Copy settings.json as-is
**Why:** The Stop hooks reference non-existent services
**DO:** Extract only UserPromptSubmit and PostToolUse sections

### ❌ DON'T: Keep example Laravel service names
**Why:** User doesn't have those specific controllers/services
**DO:** Ask about their actual Laravel structure and update

### ❌ DON'T: Skip making hooks executable
**Why:** Hooks won't run without execute permission
**DO:** Always `chmod +x` after copying

### ❌ DON'T: Assume Laravel version
**Why:** Laravel features vary significantly between versions
**DO:** Always ask which Laravel version they're using

### ❌ DON'T: Add all Laravel skills at once
**Why:** Overwhelming and may not all be relevant
**DO:** Ask what they actually need for their Laravel development

### ❌ DON'T: Copy artisan commands without testing
**Why:** Artisan commands may fail if Laravel isn't properly set up
**DO:** Test that `php artisan` works in their directory

---

## Example Laravel Integration Conversations

### Example 1: Adding Laravel Backend Skill

**User:** "Add the laravel-dev-guidelines skill to my Laravel project"

**Claude should respond:**
```
I'll add the laravel-dev-guidelines skill. First, I need to understand
your Laravel project:

1. What version of Laravel are you using?
2. Is this a standard Laravel installation or custom structure?
3. Do you use the default app/ directory for controllers and services?
```

**User:** "Laravel 11, standard installation with default directories"

**Claude should:**
1. Copy the laravel-dev-guidelines skill directory
2. Update skill-rules.json with standard Laravel pathPattern: `"app/**/*.php"`
3. Verify it's copied correctly
4. Respond:
```
✅ Added laravel-dev-guidelines skill!

Configuration:
- Skill triggers when editing files in app/, routes/, database/, config/
- Activated by keywords like "controller", "service", "model", "route"

Try it: Edit a controller in app/Http/Controllers/ and you should see the skill suggestion.
```

### Example 2: Setting Up Laravel Frontend Skill

**User:** "Set up the Laravel frontend guidelines for my Blade project"

**Claude should respond:**
```
I'll set up the Laravel frontend guidelines for your Blade project.
This requires a few questions:

1. Do you use Vite for asset compilation? (Laravel 9+)
2. Any CSS framework? (Bootstrap, Tailwind, or none)
3. Do you use Livewire or Alpine.js for interactivity?
```

**User:** "Yes to Vite, using Bootstrap 5, no Livewire"

**Claude should:**
1. Copy laravel-frontend-guidelines skill
2. Create custom skill focusing on Blade + Vite + Bootstrap
3. Update skill-rules.json for Blade files
4. Provide Bootstrap-specific examples
5. Respond:
```
✅ Set up Laravel frontend guidelines for Blade + Vite + Bootstrap!

What I configured:
- Blade component patterns
- Vite asset management
- Bootstrap 5 integration
- No Livewire/Alpine.js (as requested)

Key activation patterns:
- Editing .blade.php files
- Creating Blade components
- Working with Vite assets

Try editing resources/views/welcome.blade.php - the skill should activate.
```

### Example 3: Laravel Version Mismatch

**User:** "Add laravel-dev-guidelines to my Laravel 8 project"

**Claude should respond:**
```
The laravel-dev-guidelines skill is designed for Laravel 11+ with modern PHP 8.2+ features.
Your Laravel 8 has some differences. I have a few options:

Option 1: Adapt for Laravel 8
- Remove Laravel 11-specific features
- Keep: MVC architecture, Eloquent patterns, testing strategies
- Adjust: Route model binding, middleware examples, validation patterns

Option 2: Extract framework-agnostic patterns
- Focus on layered architecture principles
- Keep: Service patterns, repository pattern, separation of concerns
- Skip: Laravel version-specific code

Option 3: Use backend-dev-guidelines as reference
- It has Node.js patterns but the architecture principles transfer

Which would you prefer?
```

---

## Final Tips for Claude

**When user says "add everything" for Laravel:**
- Start with essentials: skill-activation hooks + 1-2 relevant Laravel skills
- Don't overwhelm them with all skills + 12 agents
- Ask what they actually need for Laravel development

**When something doesn't work in Laravel:**
- Check Laravel-specific verification checklist
- Verify Laravel version compatibility
- Test artisan commands manually
- Check for JSON syntax errors in skill-rules.json

**When user is unsure about Laravel setup:**
- Recommend starting with just skill-activation hooks
- Add laravel-dev-guidelines OR laravel-frontend-guidelines (whichever they use)
- Add more Laravel-specific skills later as needed

**Always explain what you're doing for Laravel:**
- Show the commands you're running
- Explain why you're asking about Laravel version/structure
- Provide clear next steps after integration
- Reference Laravel-specific documentation when helpful

---

**Remember:** This is a Laravel-specific reference library, not a working Laravel application. Your job is to help Laravel developers cherry-pick and adapt components for THEIR specific Laravel project structure and version.
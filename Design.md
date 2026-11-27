# TriIQ design system

The look of the TriIQ app (Android first, Windows too). Tokens live in code in
`lib/theme/design_tokens.dart` and are mapped onto Material 3 in
`lib/theme/app_theme.dart`. Change this file and the tokens together.

## Overview
An editorial, precise training companion: bold headings, calm surfaces, and
data that reads at a glance. Quietly confident, never loud. Dense where an
athlete needs numbers, with room to breathe around them. Flat by default;
colour is kept for what you can tap and for what the data says.

## Colors
Light palette (the source); dark values are derived with the same roles.

| Role | Light | Dark | Use |
|---|---|---|---|
| Primary | #6366F1 | #818CF8 | Interactive only: buttons, links, selected states, focus |
| Primary hover | #4F46E5 | — | Hover/pressed on primary |
| Secondary | #20970B | #20970B | TriIQ's own plan items (as opposed to Intervals.icu) |
| Warning (tertiary) | #F59E0B | #F59E0B | Pending, caution, planned in Intervals.icu |
| Error | #EF4444 | #EF4444 | Destructive actions, errors, red flags |
| Success | #10B981 | #10B981 | Confirmations |
| Neutral | #9C9C9C | #9C9C9C | Placeholders, disabled, outlines |
| Background | #FAFAFA | #0F0F12 | Page |
| Surface | #FFFFFF | #18181B | Cards, sheets, dialogs, bars |
| Text primary | #0A0A0A | #F4F4F5 | Headings, body |
| Text secondary | #6B6B6B | #A1A1AA | Metadata, captions |
| Border | #E8E8EC | #2E2E35 | Card borders, dividers, inputs |
| Ink | #111114 | #26262C | Flat header surfaces that carry white content |

**Data colours** (`DesignData`) carry meaning in charts and markers, never
interaction:
- Categorical series use the Okabe–Ito palette (blue #0072B2, orange #E69F00,
  green #009E73, vermillion #D55E00, purple #CC79A7), each with a lighter
  variant on dark. Sports: swim blue, ride orange, run green.
- Sequential scales use viridis (load heatmap).
- Workout intensity follows power-zone colours (recovery grey-blue through
  anaerobic purple).
- Projections and estimates are dashed and labelled "est.".
- Indigo is never a data colour.

## Typography
- **UI and headings**: DM Sans (bundled, 400 / 500 / 700).
- **Code, keys, CLI text, workout syntax**: JetBrains Mono (bundled, 400).
- General Sans, the original display font, isn't bundled; headings use DM Sans
  Bold with tight tracking (−0.03 em).

Scale: Display 72 / 60 / 44, Headline 32 / 24 / 22, Title 20 / 16 / 14,
Body 16 / 15 / 13, Label 14 / 12 / 11. No text below 11 sp at default scale;
layouts hold at 200 % text.

Weights: 700 for headings and big numbers, 500 for labels and buttons, 400 for
body. Only these three are bundled; never use 600, 800 or 900.

## Elevation
Flat. Cards rest on a 1 px border with no shadow. A shadow appears only on
hover (0 8px 30px rgba(0,0,0,0.08)) and on floating layers (menus, popovers,
snackbars). App bar and bottom bar use a 1 px border, not a shadow. Focus is a
2 px primary border.

## Components
- **Buttons**: primary = indigo fill, white text, 6 px radius, medium weight,
  38 px tall (touch target padded to 48). Secondary = outlined, 1 px border.
  Text buttons for low-emphasis actions. At most one filled primary button per
  section.
- **Cards**: surface, 1 px border, 12 px radius, clipped.
- **Headers on detail screens**: the flat ink surface with white content
  (`inkDecoration`), 12 px radius. No gradients.
- **Inputs**: surface fill, 1 px border, 6 px radius, 10 × 14 padding; focus
  turns the border indigo; errors turn it red.
- **Chips**: pill-shaped, gray-100 fill, gray-600 text, 12 px medium; selected
  = indigo fill, white text. Status chips use the semantic colours.
- **Lists**: rows with 1 px dividers, 16 px horizontal padding.
- **Checkboxes**: round; indigo when checked.
- **Navigation**: bottom bar on phones (flat, top border), a rail from 840 dp.
  56 dp app bar with a bottom border.
- **Calendar markers**: shape as well as colour — done = filled circle,
  planned in Intervals.icu = outlined circle, TriIQ plan = outlined rounded
  square.

## Spacing
- Base unit 4 px; scale 4, 8, 12, 16, 20, 24, 32, 40, 48, 64.
- Screen padding 16; gaps between cards 12.

## Border radius
- 2: hairline bars and progress tracks
- 4: tags, badges, inline code, chart bar tops
- 6: buttons, inputs, segmented buttons
- 8: panels, menus, snackbars, list tiles, small tiles
- 12: cards, dialogs, sheets, headers, search bar
- pill: chips, avatars, status dots

## Do's and Don'ts
- Do take colours from `Theme.of(context).colorScheme` or the tokens; never a
  hex literal in a widget.
- Do keep indigo for interactive elements.
- Do keep the 4 px grid.
- Do check light and dark for anything new.
- Do give shape or text alongside colour (WCAG 1.4.1).
- Don't use pure black or white for text.
- Don't add decorative gradients or illustrations. Chart area fills that fade
  out are data, not decoration.
- Don't put shadows on static elements.
- Don't use unbundled font weights (600, 800, 900).
- Don't place more than one filled primary button in one section.

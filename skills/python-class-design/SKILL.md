---
name: python-class-design
description: Use when designing or reviewing Python classes, deciding where logic belongs, or recognizing antipatterns like helper classes, utility bags, and god objects.
---

# Python Class Design

## The One Question

Before adding any method or function, ask: **which object already owns the data this logic operates on?** Put the method there. If no object owns it, that is a sign a class is missing, not that a helper is needed.

## Antipatterns to Reject

**Helper class** — a class whose methods are all static, or whose `__init__` is trivial/empty. This is a module pretending to be a class. Either make it a plain module with functions, or find the object that owns the data and add the method there.

**Utility bag** — a class named `XxxUtils`, `XxxHelper`, `XxxManager`. The name signals that responsibility assignment was avoided, not solved. These are always wrong.

**God object** — a class with more than ~5 distinct responsibilities, or exhibiting: methods >50 lines, parameters >5, nesting >4 levels, cyclomatic complexity >10. Any of these is a signal to extract a coherent cluster into a new class named for what it *is*, not what it *does*.

**Premature abstraction** — a base class, mixin, or protocol invented for one concrete use. Don't create the abstraction until the second real use case appears.

## Widget Corollary (Textual / UI frameworks)

A widget owns its own rendering. Logic that translates a widget's data into display output belongs in the widget's `render()`, `compose()`, or a method on the widget subclass — not in an external function that receives data and returns markup.

## Before / After

```python
# WRONG: helper class that takes data from outside
class WaveformRenderer:
    @staticmethod
    def render(bins, width, height): ...

art = WaveformRenderer.render(bins, w, h)
widget.update(art)

# RIGHT: the widget owns its rendering
class WaveformWidget(Static):
    def set_bins(self, bins):
        self._bins = bins
        self.refresh()
    def render(self):
        return _braille(self._bins, self.size.width, self.size.height)
```

## When a Free Function Is Correct

Pure transformations with no natural owning object — parsers, math, format conversions — belong as module-level functions, not wrapped in a class. A class requires state or a coherent identity. If neither exists, skip the class.

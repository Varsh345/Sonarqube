# src/app.py

"""
Simple sample application to demonstrate:
- Python code structure
- Unit testing
- SonarQube analysis via CI
"""

def add(a: int, b: int) -> int:
    """Return the sum of two integers."""
    return a + b


def divide(a: float, b: float) -> float:
    """Divide a by b, with basic error handling."""
    if b == 0:
        raise ValueError("Division by zero is not allowed")
    return a / b


def main() -> None:
    """Simple entry point."""
    x = 10
    y = 5
    print(f"{x} + {y} = {add(x, y)}")
    print(f"{x} / {y} = {divide(x, y)}")


if __name__ == "__main__":
    main()

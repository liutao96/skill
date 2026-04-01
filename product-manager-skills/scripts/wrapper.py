#!/usr/bin/env python3
"""
Product Manager Skills - Wrapper Script

This wrapper provides access to 46 battle-tested PM frameworks.
The actual skill files are referenced from the GitHub repo.

Usage: The AI agent reads SKILL.md and references specific frameworks
based on the user's needs.
"""

import sys
import json

def list_skills():
    """List all available PM skills by category."""
    skills = {
        "component": [
            "altitude-horizon-framework",
            "finance-based-pricing-advisor",
            "tam-sam-som-calculator",
            "user-story",
            # ... more component skills
        ],
        "interactive": [
            "director-readiness-advisor",
            "vp-cpo-readiness-advisor",
            "workshop-facilitation",
            # ... more interactive skills
        ],
        "workflow": [
            "executive-onboarding-playbook",
            # ... more workflow skills
        ]
    }
    return skills

def get_skill_info(skill_name: str) -> dict:
    """Get information about a specific skill."""
    # Reference to the GitHub repo skill files
    base_url = "https://github.com/deanpeters/Product-Manager-Skills/tree/main/skills"
    return {
        "name": skill_name,
        "url": f"{base_url}/{skill_name}/SKILL.md",
        "local_reference": f"Reference the SKILL.md in the skills/{skill_name}/ directory"
    }

def main():
    if len(sys.argv) < 2:
        print("Product Manager Skills Wrapper")
        print("Usage: python wrapper.py <command> [args]")
        print("")
        print("Commands:")
        print("  list              - List all available skills")
        print("  info <skill>      - Get info about a specific skill")
        print("  version           - Show version info")
        return

    command = sys.argv[1]

    if command == "list":
        skills = list_skills()
        print(json.dumps(skills, indent=2))

    elif command == "info" and len(sys.argv) > 2:
        skill_name = sys.argv[2]
        info = get_skill_info(skill_name)
        print(json.dumps(info, indent=2))

    elif command == "version":
        print("Product Manager Skills v0.5")
        print("GitHub: https://github.com/deanpeters/Product-Manager-Skills")
        print("Commit: 1e8ff6247c02c9d77da03a823bb8c9da3ed00884")

    else:
        print(f"Unknown command: {command}")
        print("Run without arguments for usage help.")

if __name__ == "__main__":
    main()

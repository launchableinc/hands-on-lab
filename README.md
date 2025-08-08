
# Launchable Smart Tests Workshop

## Workshop Overview

Welcome to the Launchable Smart Tests Workshop! This hands-on session is designed to help you implement predictive test selection and analysis within your Git repositories. Throughout this workshop, you'll optimize your test pipeline to ensure that only the most relevant tests are executed with every code change.

## Testing Pyramid and Best Practices

Understanding the Testing Pyramid is crucial for structuring your test suite efficiently:

- **Unit Tests (Base Layer):** These are fast, low-level tests that validate individual components or functions without external dependencies.
- **Service Tests (Middle Layer):** Focus on the integration between multiple components. These tests are slightly slower and higher-level than unit tests.
- **UI Tests (Top Layer):** High-level tests that simulate user interactions and ensure end-to-end system functionality. These are slower but critical for verifying user interface behaviors.

**Best Practices:**
- Aim to have a large number of unit tests, fewer service tests, and even fewer UI tests.
- Execute tests with clear objectives, covering both functionality and potential edge cases.

### Value of Launchable Smart Tests Automation

Launchable Smart Tests enhance the efficiency of this pyramid by automating predictive test selection. Through its intelligent analysis, Smart Tests selects the most relevant set of tests to run, reducing redundancy and maximizing resource efficiency. This automation ensures rapid feedback loops, minimizes the risk of regressions, and supports a robust Continuous Integration (CI) approach.

## Goals

- Understand the core concepts of Predictive Test Selection (PTS)
- Manage builds and test sessions effectively
- Implement targeted subsetting of tests for code changes
- Experiment with various test categories

## Table of Contents





- **Lab 0: Prerequisites**
  - [Step 0. Prerequisites](HANDSON0.md)
  - Ensure you have the necessary tools and permissions to start the workshop seamlessly.

- **Step 1: Environment Setup**
  - Set up your local and remote environments to integrate with Smart Tests.
  - [Lab 1. Environment setup](HANDSON1.md)

- **Step 2: Try Predictive Test Selection**
  - Experiment with PTS by making code changes and observing test selection.
  - [Lab 2. Try predictive test selection](HANDSON2.md)
- **Step 3: Incorporate Smart Tests into Your CI Pipeline**
  - Integrate Smart Tests into your CI pipeline for automated, efficient testing cycles.
  - [Lab 3. Incorporate Smart Tests into your CI pipeline](HANDSON3.md)

## Reference Materials

- [Smart Tests Documentation](https://www.launchableinc.com/docs/)

Explore the documentation for comprehensive insights and advanced features. This workshop aims to revolutionize your testing strategy with AI-driven precision and automated efficiency. Enjoy the process!

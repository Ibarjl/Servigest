# Work Order System

## Overview
The Work Order System is a Julia-based application designed to manage work orders, technicians, and clients. It follows a layered architecture, separating concerns into distinct layers: Domain, Application, Infrastructure, Controllers, and User Interface.

## Project Structure
- **src/**: Contains the source code for the application.
  - **domain/**: Defines the core entities and business rules.
  - **application/**: Implements use cases and defines interfaces for infrastructure.
  - **infrastructure/**: Contains data persistence and external services.
  - **controllers/**: Manages user input and output for different interfaces.
  - **ui/**: Handles presentation logic for CLI and web interfaces.
  
- **test/**: Contains tests for various layers of the application to ensure functionality and reliability.

- **Project.toml**: Lists the dependencies and package information for the project.

- **Manifest.toml**: Contains resolved dependencies for reproducibility.

## Getting Started

### Prerequisites
- Julia 1.x or higher
- Required packages as specified in `Project.toml`

### Installation
1. Clone the repository:
   ```
   git clone <repository-url>
   cd Servigest
   ```

2. Activate the project environment:
   ```
   julia --project=.
   ```

3. Install dependencies:
   ```
   using Pkg
   Pkg.instantiate()
   ```

### Running the Application
To run the application, you can use the command-line interface:
```
julia --project=. src/controllers/cli_controller.jl
```

### Running Tests
To run the tests, execute:
```
julia --project=. test/runtests.jl
```

## Usage
- Create work orders, assign technicians, and manage clients through the CLI or web interface.
- Follow the prompts in the CLI for user-friendly interaction.

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.
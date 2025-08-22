# PongShots

A ping-pong game designed to demonstrate real-world DevOps practices, showcasing the complete lifecycle from development to production deployment.

This project serves as a comprehensive example of modern DevOps operations, integrating:
- **Software Development** - Java-based game application
- **CI/CD Pipelines** - Automated testing and deployment workflows
- **Infrastructure as Code** - Terraform for AWS infrastructure management
- **Containerization** - Docker for application packaging and deployment

## Directory Structure

```
PongShots/
├── Dockerfile
├── Java/
│   ├── gradle.properties
│   ├── gradlew
│   ├── gradlew.bat
│   ├── settings.gradle
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/
│   │       ├── main/
│   │       │   ├── java/
│   │       │   └── resources/
│   │       └── test/
│   │           ├── java/
│   │           └── resources/
│   └── gradle/
└── terraform/
    ├── locals.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfvars
    ├── variables.tf
    ├── initScripts/
    │   ├── cloud-init.sh
    │   └── docker-compose.yml
    ├── keys/
    └── scripts/
        └── run.sh
```

## Technologies Used

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Application** | Java + Gradle | Core ping-pong game with build automation |
| **Infrastructure** | Terraform + AWS | Automated cloud infrastructure provisioning |
| **Containerization** | Docker + Docker Compose | Application packaging and orchestration |
| **CI/CD** | GitHub Actions | Automated testing, building, and deployment |
| **Container Registry** | GitHub Packages | Docker image storage and distribution |
| **Monitoring** | Watchtower | Automated container updates |

## Quick Start

### Prerequisites
- Java 11 or higher
- Docker and Docker Compose
- Terraform
- AWS CLI configured
- Git

### Local Development
1. **Build the application:**
   ```bash
   cd Java
   ./gradlew build
   ```

2. **Run tests:**
   ```bash
   ./gradlew test
   ```

3. **View build artifacts:**
   - Check the `build/` directory for compiled classes and JARs

### Container Deployment
1. **Build Docker image:**
   ```bash
   docker build -t pongshots:latest .
   ```

2. **Run locally:**
   ```bash
   docker run -p 8080:8080 pongshots:latest
   ```

### Infrastructure Deployment
1. **Configure AWS credentials:**
   ```bash
   cd terraform/scripts
   # Create .env file with AWS credentials (see configuration section)
   ```

2. **Deploy infrastructure:**
   ```bash
   ./run.sh plan    # Review changes
   ./run.sh apply   # Deploy to AWS
   ```

## Detailed Setup

### Application Development
The Java application uses Gradle for build management and testing.

**Build Commands:**
```bash
cd Java
./gradlew build          # Compile and build the application
./gradlew test           # Run unit tests
./gradlew clean          # Clean build artifacts
./gradlew bootRun        # Run the application locally
```

**Project Structure:**
- `src/main/java/` - Application source code
- `src/test/java/` - Unit tests
- `build.gradle` - Build configuration and dependencies

### API Endpoints
The PongShots application provides the following REST API endpoints:

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `/` | GET | Home endpoint with welcome message | None | JSON with message, status, and optional details |
| `/game/start` | POST | Start a new game session | None | JSON with success message and current score (0) |
| `/game/status` | GET | Get current game status | None | JSON with `gameStarted` (boolean) and `pongShots` (score) |
| `/game/pongshot` | POST | Make a pong shot with specified power | `{"power": 1-100}` | JSON with success message and updated score |
| `/game/reset` | POST | Reset the current game score to 0 | None | JSON with success message |
| `/game/stop` | POST | Stop the current game session | None | JSON with success message and reset score |

**Endpoint Details:**

**GET `/`**
- Optional query parameter: `?detailed=true` for additional version and timestamp info
- Always returns HTTP 200

**POST `/game/start`**
- Returns HTTP 200 if game started successfully
- Returns HTTP 304 if game is already started

**GET `/game/status`**  
- Always returns HTTP 200
- Shows current game state and accumulated score

**POST `/game/pongshot`**
- Requires JSON body with `power` field (integer 1-100)
- Returns HTTP 400 if game not started or invalid power value
- Returns HTTP 200 with updated accumulated score

**POST `/game/reset`**
- Returns HTTP 400 if game not started
- Returns HTTP 200 if reset successful (score becomes 0)

**POST `/game/stop`**
- Returns HTTP 400 if game not started  
- Returns HTTP 200 and resets score to 0

### Container Configuration
The application is containerized using Docker with automatic updates via Watchtower.

**Container Architecture:**
1. **Application Container:**
   - Hosts the Java PongShots game
   - Exposes port 8080
   - Built from the root Dockerfile
   - Automatically updated by Watchtower

2. **Watchtower Container:**
   - Monitors for new image versions
   - Pulls updates from GitHub Packages
   - Restarts containers with zero-downtime deployment
   - Configurable update interval (default: 30 seconds)

**Configuration Steps:**
1. **Build and push custom image:**
   ```bash
   docker build -t [REGISTRY]/pongshots:[TAG] .
   docker push [REGISTRY]/pongshots:[TAG]
   ```

2. **Update Docker Compose:**
   - Edit `terraform/initScripts/docker-compose.yml`
   - Change the `image` field to your custom image
   - Modify `SERVER_HOST` if needed (default: `0.0.0.0`)

### Infrastructure Management
Terraform automates AWS infrastructure provisioning and management.

**Setup Requirements:**
1. **Create environment configuration:**
   ```bash
   cd terraform/scripts
   touch .env
   ```

2. **Configure `.env` file:**
   ```bash
   AWS_ACCESS_KEY_ID=your_access_key
   AWS_SECRET_ACCESS_KEY=your_secret_key
   AWS_DEFAULT_REGION=your_preferred_region
   ```

**Terraform Variables:**
| Variable | Description | Default Value |
|----------|-------------|---------------|
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `tag` | Resource tags | `prod` |
| `watchtower_interval` | Update check interval (seconds) | `30` |
| `ssh_key_path` | SSH public key location | `./keys/vm-ssh-key.pub` |

**Deployment Commands:**
```bash
cd terraform/scripts
./run.sh plan     # Preview infrastructure changes
./run.sh apply    # Deploy infrastructure
./run.sh destroy  # Tear down infrastructure
```

**Outputs:**
- `vm_username` - EC2 instance username (ubuntu)
- `vm_ip` - Public IP address for accessing the application

### CI/CD Pipeline
GitHub Actions provides automated testing and deployment workflows.

**Pipeline Architecture:**

1. **Test Pipeline (Pull Requests):**
   - **Trigger:** PR to `master` branch
   - **Condition:** Changes in `Java/` directory
   - **Actions:**
     - Code checkout
     - Java environment setup
     - Gradle build and test execution
     - Test result reporting

2. **Build & Deploy Pipeline (Master Branch):**
   - **Trigger:** Successful merge to `master`
   - **Prerequisites:** Test pipeline must pass
   - **Actions:**
     - Application build
     - Docker image creation
     - Push to GitHub Packages
     - Automatic deployment via Watchtower

**Configuration for Forked Repositories:**
If you fork this repository, update the following in `.github/workflows/build-and-push.yml`:

1. **Update the container registry reference:**
   ```yaml
   # Update the registry URL under "Build Docker Image" step
   registry: ghcr.io/[YOUR_USERNAME]/pongshots
   ```

2. **Configure Docker login credentials:**
   ```yaml
   # Update the Docker login step to match your registry
   - name: Login to Container Registry
     uses: docker/login-action@v2
     with:
       registry: ghcr.io  # Change to your registry (docker.io, gcr.io, etc.)
       username: ${{ github.actor }}  # Update for your registry authentication
       password: ${{ secrets.GITHUB_TOKEN }}  # Use appropriate secret for your registry
   ```

   **Common registry configurations:**
   - **Docker Hub:** `registry: docker.io`, use `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets
   - **Google Container Registry:** `registry: gcr.io`, use service account credentials
   - **AWS ECR:** `registry: [account].dkr.ecr.[region].amazonaws.com`, use AWS credentials

## Usage

### Accessing the Application
Once deployed, access your PongShots game at:
```
http://[VM_IP]:8080
```

### Monitoring and Maintenance
- **Container Updates:** Automatic via Watchtower
- **Infrastructure Changes:** Use Terraform scripts
- **Application Logs:** Access via SSH to the EC2 instance

### Development Workflow
1. Make changes to the Java application
2. Create a Pull Request to `master`
3. Automated tests run and validate changes
4. After merge, automatic build and deployment occurs
5. Watchtower updates the running container


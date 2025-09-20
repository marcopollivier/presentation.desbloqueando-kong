use std::env;
use std::sync::Arc;
use std::time::Instant;
use tokio::time::Instant as TokioInstant;
use warp::{http::StatusCode, Filter, Rejection, Reply};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Post {
    id: u32,
    title: String,
    body: String,
    #[serde(rename = "userId")]
    user_id: u32,
    server_info: ServerInfo,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct User {
    id: u32,
    name: String,
    email: String,
    server_info: ServerInfo,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ServerInfo {
    language: String,
    server: String,
    port: String,
    timestamp: String,
    uptime: String,
}

#[derive(Debug, Clone, Serialize)]
struct HealthResponse {
    status: String,
    language: String,
    server: String,
    port: String,
    timestamp: String,
    uptime: String,
    memory: MemoryInfo,
    threads: String,
}

#[derive(Debug, Clone, Serialize)]
struct MemoryInfo {
    rss: String,
    threads: u32,
}

#[derive(Debug, Clone, Serialize)]
struct PerformanceResponse {
    language: String,
    server: String,
    timestamp: String,
    result: u64,
    processing_time: u128,
    concurrency: String,
    threads: String,
}

#[derive(Debug, Clone, Serialize)]
struct ErrorResponse {
    error: String,
    server_info: ServerInfo,
}

#[derive(Debug, Clone)]
struct AppState {
    server_name: String,
    port: String,
    start_time: TokioInstant,
    posts: Vec<Post>,
    users: Vec<User>,
}

impl AppState {
    fn new() -> Self {
        let server_name = env::var("SERVER_NAME").unwrap_or_else(|_| "rust-mock-api-3".to_string());
        let port = env::var("PORT").unwrap_or_else(|_| "3003".to_string());
        let start_time = TokioInstant::now();

        // Initialize mock data
        let posts = vec![
            Post {
                id: 1,
                title: "Post 1".to_string(),
                body: "This is post 1".to_string(),
                user_id: 1,
                server_info: ServerInfo::new(&server_name, &port, start_time),
            },
            Post {
                id: 2,
                title: "Post 2".to_string(),
                body: "This is post 2".to_string(),
                user_id: 1,
                server_info: ServerInfo::new(&server_name, &port, start_time),
            },
            Post {
                id: 3,
                title: "Post 3".to_string(),
                body: "This is post 3".to_string(),
                user_id: 2,
                server_info: ServerInfo::new(&server_name, &port, start_time),
            },
        ];

        let users = vec![
            User {
                id: 1,
                name: "John Doe".to_string(),
                email: "john@example.com".to_string(),
                server_info: ServerInfo::new(&server_name, &port, start_time),
            },
            User {
                id: 2,
                name: "Jane Smith".to_string(),
                email: "jane@example.com".to_string(),
                server_info: ServerInfo::new(&server_name, &port, start_time),
            },
        ];

        AppState {
            server_name,
            port,
            start_time,
            posts,
            users,
        }
    }

    fn create_server_info(&self) -> ServerInfo {
        ServerInfo::new(&self.server_name, &self.port, self.start_time)
    }
}

impl ServerInfo {
    fn new(server_name: &str, port: &str, start_time: TokioInstant) -> Self {
        let uptime = start_time.elapsed();
        ServerInfo {
            language: "Rust".to_string(),
            server: server_name.to_string(),
            port: port.to_string(),
            timestamp: chrono::Utc::now().to_rfc3339(),
            uptime: format!("{:.3}s", uptime.as_secs_f64()),
        }
    }
}

// Health check handler
async fn health_handler(state: Arc<AppState>) -> Result<impl Reply, Rejection> {
    let uptime = state.start_time.elapsed();
    
    let response = HealthResponse {
        status: "healthy".to_string(),
        language: "Rust".to_string(),
        server: state.server_name.clone(),
        port: state.port.clone(),
        timestamp: chrono::Utc::now().to_rfc3339(),
        uptime: format!("{:.3}s", uptime.as_secs_f64()),
        memory: MemoryInfo {
            rss: "N/A".to_string(),
            threads: num_cpus::get() as u32,
        },
        threads: "async tokio".to_string(),
    };

    Ok(warp::reply::with_status(
        warp::reply::json(&response),
        StatusCode::OK,
    ))
}

// Get all posts handler
async fn get_posts_handler(state: Arc<AppState>) -> Result<impl Reply, Rejection> {
    let mut posts = state.posts.clone();
    for post in &mut posts {
        post.server_info = state.create_server_info();
    }
    
    Ok(warp::reply::json(&posts))
}

// Get post by ID handler
async fn get_post_handler(id: u32, state: Arc<AppState>) -> Result<impl Reply, Rejection> {
    if let Some(mut post) = state.posts.iter().find(|p| p.id == id).cloned() {
        post.server_info = state.create_server_info();
        Ok(warp::reply::with_status(
            warp::reply::json(&post),
            StatusCode::OK,
        ).into_response())
    } else {
        let error = ErrorResponse {
            error: "Post not found".to_string(),
            server_info: state.create_server_info(),
        };
        Ok(warp::reply::with_status(
            warp::reply::json(&error),
            StatusCode::NOT_FOUND,
        ).into_response())
    }
}

// Get all users handler
async fn get_users_handler(state: Arc<AppState>) -> Result<impl Reply, Rejection> {
    let mut users = state.users.clone();
    for user in &mut users {
        user.server_info = state.create_server_info();
    }
    
    Ok(warp::reply::json(&users))
}

// Get user by ID handler
async fn get_user_handler(id: u32, state: Arc<AppState>) -> Result<impl Reply, Rejection> {
    if let Some(mut user) = state.users.iter().find(|u| u.id == id).cloned() {
        user.server_info = state.create_server_info();
        Ok(warp::reply::with_status(
            warp::reply::json(&user),
            StatusCode::OK,
        ).into_response())
    } else {
        let error = ErrorResponse {
            error: "User not found".to_string(),
            server_info: state.create_server_info(),
        };
        Ok(warp::reply::with_status(
            warp::reply::json(&error),
            StatusCode::NOT_FOUND,
        ).into_response())
    }
}

// Performance benchmark handler
async fn performance_handler(state: Arc<AppState>) -> Result<impl Reply, Rejection> {
    let start = Instant::now();
    
    // CPU-intensive task (calculating sum)
    let mut result: u64 = 0;
    for i in 0..100000 {
        result = result.wrapping_add(i);
    }
    
    let processing_time = start.elapsed().as_micros();
    
    let response = PerformanceResponse {
        language: "Rust".to_string(),
        server: state.server_name.clone(),
        timestamp: chrono::Utc::now().to_rfc3339(),
        result,
        processing_time,
        concurrency: "async/await tokio".to_string(),
        threads: format!("{}x tokio worker threads", num_cpus::get()),
    };
    
    Ok(warp::reply::json(&response))
}

// Create application state filter
fn with_state(state: Arc<AppState>) -> impl Filter<Extract = (Arc<AppState>,), Error = std::convert::Infallible> + Clone {
    warp::any().map(move || state.clone())
}

#[tokio::main]
async fn main() {
    let state = Arc::new(AppState::new());
    let port: u16 = state.port.parse().unwrap_or(3003);
    
    // Health check route
    let health = warp::path("health")
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(health_handler);

    // Posts routes
    let posts = warp::path("posts")
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(get_posts_handler);

    let post = warp::path("posts")
        .and(warp::path::param::<u32>())
        .and(warp::path::end())
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(get_post_handler);

    // Users routes
    let users = warp::path("users")
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(get_users_handler);

    let user = warp::path("users")
        .and(warp::path::param::<u32>())
        .and(warp::path::end())
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(get_user_handler);

    // Performance route
    let performance = warp::path("performance")
        .and(warp::get())
        .and(with_state(state.clone()))
        .and_then(performance_handler);

    // Combine all routes
    let routes = health
        .or(posts)
        .or(post)
        .or(users)
        .or(user)
        .or(performance)
        .with(warp::cors().allow_any_origin());

    println!("🚀 Rust Mock API Server ({}) running on port {}", state.server_name, port);
    println!("📊 Performance endpoint: http://localhost:{}/performance", port);
    println!("💚 Health check: http://localhost:{}/health", port);

    warp::serve(routes)
        .run(([0, 0, 0, 0], port))
        .await;
}

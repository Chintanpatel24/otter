use std::fs;
use std::path::PathBuf;

pub fn get_config_path() -> PathBuf {
    let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
    PathBuf::from(home).join(".config").join("otter").join("config.json")
}

pub fn load_config() -> Result<String, String> {
    let path = get_config_path();
    fs::read_to_string(path.as_path())
        .map_err(|e| format!("Failed to read config: {}", e))
}

pub fn save_config(data: &str) -> Result<(), String> {
    let path = get_config_path();
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).map_err(|e| format!("Failed to create config dir: {}", e))?;
    }
    fs::write(path.as_path(), data)
        .map_err(|e| format!("Failed to write config: {}", e))
}

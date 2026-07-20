use std::fs;
pub fn export_chat_results(lines: &Vec<(String, String)>, path: &str) {
    let content = lines.iter().map(|(r, m)| format!("[{}] {}", r, m)).collect::<Vec<_>>().join("\n");
    fs::write(path, content).unwrap();
}
pub fn export_json(data: &str, path: &str) {
    fs::write(path, data).unwrap();
}

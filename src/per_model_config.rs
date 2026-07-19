use std::collections::HashMap;
pub struct PerModelConfig {
    pub settings: HashMap<String, serde_json::Value>,
}
impl PerModelConfig {
    pub fn new() -> Self {
        Self { settings: HashMap::new() }
    }
    pub fn set_for_model(&mut self, model: &str, max_tokens: usize, temperature: f32) {
        let mut val = serde_json::Map::new();
        val.insert("max_tokens".to_string(), max_tokens.into());
        val.insert("temperature".to_string(), serde_json::Value::from(temperature));
        self.settings.insert(model.to_string(), serde_json::Value::Object(val));
    }
    pub fn get_for_model(&self, model: &str) -> Option<&serde_json::Value> {
        self.settings.get(model)
    }
}

use crate::engine_bindings::Engine;
use eframe::egui;
use std::path::PathBuf;

pub struct OtterApp {
    engine: Engine,
    model_path: Option<String>,
    chat_lines: Vec<(String, String)>,
    input_text: String,
    status_line: String,
    dark_mode: bool,
    show_settings: bool,
    show_mesh: bool,
    max_tokens: usize,
    temperature: f32,
    per_model_config: crate::per_model_config::PerModelConfig,
}

impl Default for OtterApp {
    fn default() -> Self {
        Self {
            engine: Engine::new(),
            model_path: None,
            chat_lines: Vec::new(),
            input_text: String::new(),
            status_line: String::from("Ready"),
            dark_mode: true,
            show_settings: false,
            show_mesh: false,
            max_tokens: 256,
            temperature: 0.8,
            per_model_config: crate::per_model_config::PerModelConfig::new(),
        }
    }
}

impl OtterApp {
    pub fn new(_cc: &eframe::CreationContext) -> Self {
        Self::default()
    }

    fn load_model(&mut self, path: &str) {
        match self.engine.init_model(path) {
            Ok(msg) => {
                self.status_line = msg;
                self.chat_lines.push(("system".to_string(), format!("Engine initialized: {}", path)));
                if let Some(config) = self.per_model_config.get_for_model(path) {
                    if let Some(obj) = config.as_object() {
                        if let Some(max_tok) = obj.get("max_tokens").and_then(|v| v.as_u64()) {
                            self.max_tokens = max_tok as usize;
                        }
                        if let Some(temp) = obj.get("temperature").and_then(|v| v.as_f64()) {
                            self.temperature = temp as f32;
                        }
                    }
                }
            }
            Err(e) => {
                self.status_line = format!("Error: {}", e);
                self.chat_lines.push(("system".to_string(), format!("Load failed: {}", e)));
            }
        }
    }

    fn send(&mut self) {
        let text = self.input_text.trim().to_string();
        if text.is_empty() {
            return;
        }
        self.chat_lines.push(("user".to_string(), text.clone()));
        self.input_text.clear();
        if self.engine.is_active() {
            match self.engine.generate_from_text(&text) {
                Ok(resp) => self.chat_lines.push(("assistant".to_string(), resp)),
                Err(e) => self.chat_lines.push(("system".to_string(), format!("Generation error: {}", e))),
            }
        } else {
            self.chat_lines.push(("system".to_string(), "Engine inactive".to_string()));
        }
    }
}

impl eframe::App for OtterApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        // Apply theme: dark = matte black (#121212), light = pure white (#ffffff)
        if self.dark_mode {
            let mut visuals = egui::style::Visuals::dark();
            visuals.window_fill = egui::Color32::from_rgb(0x12, 0x12, 0x12);
            visuals.panel_fill = egui::Color32::from_rgb(0x1a, 0x1a, 0x1a);
            visuals.faint_bg_color = egui::Color32::from_rgb(0x0f, 0x0f, 0x0f);
            visuals.extreme_bg_color = egui::Color32::from_rgb(0x12, 0x12, 0x12);
            visuals.code_bg_color = egui::Color32::from_rgb(0x22, 0x22, 0x22);
            visuals.widgets.inactive.bg_fill = egui::Color32::from_rgb(0x2a, 0x2a, 0x2a);
            visuals.widgets.active.bg_fill = egui::Color32::from_rgb(0x3a, 0x3a, 0x3a);
            visuals.widgets.hovered.bg_fill = egui::Color32::from_rgb(0x38, 0x38, 0x38);
            visuals.override_text_color = Some(egui::Color32::from_rgb(0xf0, 0xf0, 0xf0));
            visuals.widgets.noninteractive.bg_fill = egui::Color32::from_rgb(0x22, 0x22, 0x22);
            ctx.set_visuals(visuals);
        } else {
            let mut visuals = egui::style::Visuals::light();
            visuals.window_fill = egui::Color32::from_rgb(0xff, 0xff, 0xff);
            visuals.panel_fill = egui::Color32::from_rgb(0xf8, 0xf8, 0xf8);
            visuals.faint_bg_color = egui::Color32::from_rgb(0xf0, 0xf0, 0xf0);
            visuals.extreme_bg_color = egui::Color32::from_rgb(0xff, 0xff, 0xff);
            visuals.widgets.inactive.bg_fill = egui::Color32::from_rgb(0xe5, 0xe5, 0xe5);
            visuals.widgets.active.bg_fill = egui::Color32::from_rgb(0xd0, 0xd0, 0xd0);
            visuals.widgets.hovered.bg_fill = egui::Color32::from_rgb(0xc8, 0xc8, 0xc8);
            visuals.override_text_color = Some(egui::Color32::from_rgb(0x1a, 0x1a, 0x1a));
            visuals.widgets.noninteractive.bg_fill = egui::Color32::from_rgb(0xe8, 0xe8, 0xe8);
            ctx.set_visuals(visuals);
        }

        if let Some(ref path) = self.model_path {
            self.per_model_config.set_for_model(path, self.max_tokens, self.temperature);
        }

        // Minimal top bar with branding
        egui::TopBottomPanel::top("top_bar").show(ctx, |ui| {
            ui.horizontal(|ui| {
                ui.add_space(12.0);
                // Logo image
                ui.image(egui::include_image!("../assets/logo.png"));
                ui.add_space(8.0);
                ui.heading("Otter");
                ui.add_space(4.0);
                ui.label(egui::RichText::new("Local Engine").size(12.0).color(egui::Color32::GRAY));
                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    if ui.button("Theme").clicked() {
                        self.dark_mode = !self.dark_mode;
                    }
                    if ui.button("Settings").clicked() {
                        self.show_settings = !self.show_settings;
                    }
                    if ui.button("Export").clicked() {
                        crate::export::export_chat_results(&self.chat_lines, "chat_export.txt");
                        self.status_line = "Chat exported to chat_export.txt".to_string();
                    }
                    if ui.button("Update Check").clicked() {
                        if let Some(msg) = crate::update::check_for_updates() {
                            self.status_line = format!("Update: {}", msg);
                        }
                    }
                });
            });
            ui.separator();
        });

        // Left sidebar
        egui::SidePanel::left("sidebar").min_width(240.0).show(ctx, |ui| {
            ui.add_space(8.0);

            ui.heading("Model");
            ui.separator();
            ui.horizontal(|ui| {
                if ui.button("Select Model").clicked() {
                    if let Some(p) = rfd::FileDialog::new().add_filter("GGUF", &["gguf"]).pick_file() {
                        let path_str = p.display().to_string();
                        self.model_path = Some(path_str.clone());
                        self.load_model(&path_str);
                    }
                }
                if ui.button("Load").clicked() {
                    if let Some(p) = self.model_path.clone() {
                        self.load_model(&p);
                    }
                }
            });
            if let Some(p) = &self.model_path {
                ui.label(p);
            }
            ui.add_space(12.0);

            ui.heading("Drop Model");
            ui.separator();
            ui.label("Drag and drop a .gguf file or paste a URL below.");
            ui.add_space(4.0);

            // Drag and drop zone: accept .gguf files
            let drop_rect = ui.min_rect();
            ui.interact(drop_rect, ui.id().with("drop_zone"), egui::Sense::click_and_drag());
            let input = ui.ctx().input(|i| i.raw.dropped_files.clone());
            if !input.is_empty() {
                for dropped in input {
                    if let Some(p) = dropped.path {
                        if p.extension().and_then(|s| s.to_str()) == Some("gguf") {
                            let target_dir = std::env::var("HOME").unwrap_or(".".to_string()) + "/.config/otter/models/";
                            std::fs::create_dir_all(&target_dir).unwrap();
                            let file_name = p.file_name().unwrap().to_string_lossy().to_string();
                            std::fs::copy(&p, std::path::Path::new(&target_dir).join(&file_name)).unwrap();
                            self.status_line = format!("Model saved: {}", file_name);
                        }
                    }
                }
            }
            ui.add_space(12.0);

            ui.heading("Paste URL");
            ui.separator();
            ui.label("Paste Hugging Face model URL below.");
            let mut url_input: String = String::new();
            ui.add(egui::TextEdit::singleline(&mut url_input).hint_text("https://huggingface.co/...").desired_width(f32::INFINITY));
            if ui.button("Fetch URL").clicked() && !url_input.is_empty() {
                self.status_line = format!("Fetching: {}", url_input);
                // Call fetch script framework
                let output = std::process::Command::new("bash")
                    .arg("/home/user/scripts/fetch.sh")
                    .arg(&url_input)
                    .output();
                if output.is_ok() {
                    self.status_line = format!("Fetched: {}", url_input);
                }
            }

            ui.heading("Status");
            ui.separator();
            ui.label(&self.status_line);
            ui.add_space(12.0);

                ui.heading("Configuration");
                ui.separator();
                ui.add(egui::Slider::new(&mut self.max_tokens, 1..=1024).text("Max tokens"));
                ui.add(egui::Slider::new(&mut self.temperature, 0.0..=2.0).step_by(0.05).text("Temperature"));
                ui.separator();
                if ui.button("Mesh View").clicked() {
                    self.show_mesh = !self.show_mesh;
                }
                ui.add_space(16.0);
            ui.label(egui::RichText::new("Engine: Custom C").small());
            ui.label(egui::RichText::new("GPU: CUDA available").small());
        });

        // Main chat area
        egui::CentralPanel::default().show(ctx, |ui| {
            ui.heading("Chat");
            ui.separator();
            ui.add_space(4.0);

            // Chat scroll area
            egui::ScrollArea::vertical()
                .auto_shrink([false; 2])
                .stick_to_bottom(true)
                .show(ui, |ui| {
                    for (role, msg) in &self.chat_lines {
                        let bubble_color = match role.as_str() {
                            "user" => egui::Color32::from_rgb(40, 80, 140),
                            "assistant" => egui::Color32::from_rgb(30, 120, 80),
                            "system" => egui::Color32::from_rgb(140, 100, 30),
                            _ => egui::Color32::from_rgb(80, 80, 80),
                        };
                        ui.horizontal(|ui| {
                            ui.add_space(4.0);
                            ui.vertical(|ui| {
                                ui.colored_label(bubble_color, role.to_uppercase());
                                ui.add_space(2.0);
                                ui.label(msg);
                            });
                        });
                        ui.add_space(6.0);
                    }
                });

            // Mesh Window - Peer-to-Peer Network Visualization
            if self.show_mesh {
                egui::Window::new("Mesh Network - Peer to Peer")
                    .collapsible(false)
                    .resizable(true)
                    .default_width(600.0)
                    .default_height(400.0)
                    .show(ctx, |ui| {
                        ui.heading("Connected Hardware Nodes");
                        ui.separator();
                        ui.label("Force direction graph - load distributed across peers.");
                        ui.add_space(8.0);

                        // Node visualization with load bars
                        let nodes = vec![
                            ("local-main", 0.95, 0.35, vec!["otter-base".to_string()]),
                            ("remote-01", 0.70, 0.55, vec!["otter-tiny".to_string()]),
                            ("remote-02", 0.85, 0.20, vec!["otter-large".to_string(), "otter-base".to_string()]),
                        ];

                        for (name, cap, load, models) in nodes {
                            ui.horizontal(|ui| {
                                ui.vertical(|ui| {
                                    ui.set_min_width(80.0);
                                    ui.heading(name);
                                    ui.label(format!("cap: {:.1}", cap));
                                });
                                ui.add_space(4.0);
                                ui.vertical(|ui| {
                                    ui.set_min_width(120.0);
                                    // Load bar representation
                                    let bar_color = if load < 0.5 {
                                        egui::Color32::from_rgb(30, 140, 80)
                                    } else if load < 0.8 {
                                        egui::Color32::from_rgb(220, 160, 30)
                                    } else {
                                        egui::Color32::from_rgb(220, 60, 60)
                                    };
                                    ui.add(egui::ProgressBar::new(load as f32)
                                        .show_percentage()
                                        .fill(bar_color));
                                });
                                ui.add_space(4.0);
                                ui.vertical(|ui| {
                                    ui.set_min_width(100.0);
                                    for m in models {
                                        ui.label(format!("Running: {}", m));
                                    }
                                });
                            });
                            ui.separator();
                        }

                        ui.add_space(8.0);
                        if ui.button("Refresh Mesh Status").clicked() {
                            self.status_line = "Mesh refreshed.".to_string();
                        }
                        ui.horizontal(|ui| {
                            ui.label("Peer mode: enabled");
                            ui.label("Architecture: peer-to-peer");
                            ui.label("Load display: bars");
                        });
                    });
            }

            // Settings overlay (minimal popup style)
            if self.show_settings {
                egui::Window::new("Configuration")
                    .collapsible(false)
                    .resizable(false)
                    .anchor(egui::Align2::CENTER_CENTER, [0.0, -40.0])
                    .default_width(400.0)
                    .show(ctx, |ui| {
                        ui.heading("Advanced Settings");
                        ui.separator();
                        ui.add(egui::Slider::new(&mut self.max_tokens, 1..=2048).text("Max new tokens"));
                        ui.add(egui::Slider::new(&mut self.temperature, 0.0..=2.0).step_by(0.05).text("Temperature"));
                        ui.add_space(8.0);
                        ui.horizontal(|ui| {
                            ui.label("Theme:");
                            ui.selectable_value(&mut self.dark_mode, true, "Dark");
                            ui.selectable_value(&mut self.dark_mode, false, "Light");
                        });
                        if ui.button("Close").clicked() {
                            self.show_settings = false;
                        }
                    });
            }

            // Input area at bottom
            ui.add_space(8.0);
            ui.separator();
            ui.horizontal(|ui| {
                ui.add_sized(
                    [ui.available_width() - 80.0, 32.0],
                    egui::TextEdit::multiline(&mut self.input_text)
                        .hint_text("Type your message...")
                        .desired_width(f32::INFINITY)
                        .frame(false),
                );
                if ui.button("Send").clicked() {
                    self.send();
                }
            });

            ui.add_space(4.0);
            ui.colored_label(
                if self.dark_mode { egui::Color32::LIGHT_GRAY } else { egui::Color32::DARK_GRAY },
                &self.status_line,
            );
        });
    }
}
// Arena comparison module (Rust): compares answers from different models side-by-side
pub fn compare_arena_results(results: Vec<(String, String)>) -> String {
    let mut output = String::from("Arena Results (Side-by-Side):\n");
    for (model, response) in results {
        output.push_str(&format!("\n--- Model: {} ---\n{}\n", model, response));
    }
    output
}
// Real-time stream panel (Rust): live token rate tracking
pub fn live_token_rate(start: std::time::Instant, tokens: usize) -> f32 {
    let elapsed = start.elapsed().as_secs_f32();
    if elapsed > 0.0 { tokens as f32 / elapsed } else { 0.0 }
}

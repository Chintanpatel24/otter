use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int};

#[repr(C)]
pub struct OtterEngineState {
    loaded: c_int,
    path: [c_char; 512],
    max_ctx: c_int,
    layers: c_int,
    dim: c_int,
}

extern "C" {
    fn otter_init(state: *mut OtterEngineState, model_path: *const c_char) -> c_int;
    fn otter_cleanup(state: *mut OtterEngineState);
    fn otter_forward(
        input_ids: *const c_int,
        input_len: c_int,
        logits: *mut f32,
        max_len: c_int,
        state: *mut OtterEngineState,
    ) -> c_int;
    fn otter_sample(logits: *const f32, size: c_int) -> c_int;
    fn otter_tokenize(text: *const c_char, out: *mut c_int, max_out: c_int) -> c_int;
    fn otter_detokenize(ids: *const c_int, count: c_int, text: *mut c_char, max_text: c_int) -> c_int;
}

pub struct Engine {
    state: OtterEngineState,
    active: bool,
}

impl Engine {
    pub fn new() -> Self {
        Self {
            state: OtterEngineState {
                loaded: 0,
                path: [0; 512],
                max_ctx: 512,
                layers: 1,
                dim: 64,
            },
            active: false,
        }
    }

    pub fn init_model(&mut self, path: &str) -> Result<String, String> {
        let c_path = CString::new(path).map_err(|_| "Invalid path".to_string())?;
        unsafe {
            let res = otter_init(&mut self.state, c_path.as_ptr());
            if res == 0 {
                self.active = true;
                Ok(format!("Engine initialized. Model: {}", path))
            } else {
                Err("Failed to initialize engine".to_string())
            }
        }
    }

    pub fn generate_from_text(&self, text: &str) -> Result<String, String> {
        if !self.active {
            return Err("Engine not active".to_string());
        }
        let c_text = CString::new(text).map_err(|_| "Invalid text".to_string())?;
        let mut ids = [0i32; 128];
        let count = unsafe { otter_tokenize(c_text.as_ptr(), ids.as_mut_ptr(), 128) };
        if count <= 0 {
            return Err("Tokenization failed".to_string());
        }
        let mut logits = [0.0f32; 512];
        let res = unsafe {
            otter_forward(
                ids.as_ptr(),
                count,
                logits.as_mut_ptr(),
                512,
                std::ptr::addr_of!(self.state) as *mut OtterEngineState,
            )
        };
        if res != 0 {
            return Err("Forward pass failed".to_string());
        }
        let best_id = unsafe { otter_sample(logits.as_ptr(), 512) };
        let mut best_ids = [best_id];
        let mut buffer = [0i8; 256];
        unsafe {
            otter_detokenize(best_ids.as_ptr(), 1, buffer.as_mut_ptr(), 256);
        }
        let result = unsafe {
            CStr::from_ptr(buffer.as_ptr() as *const c_char)
                .to_string_lossy()
                .into_owned()
        };
        Ok(format!("Predicted token ID {} (value: {})", best_id, result.trim()))
    }

    pub fn is_active(&self) -> bool {
        self.active
    }
}

import React, { useState } from 'react';
import { ArrowLeft, ShieldCheck, ShieldAlert, Delete } from 'lucide-react';

export default function AdminPasscodeScreen({ onNavigate, mockLogin }) {
  const [pin, setPin] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleKeyPress = (num) => {
    if (pin.length < 4) {
      const newPin = pin + num;
      setPin(newPin);
      setError('');
      
      // Auto submit on 4 digits
      if (newPin.length === 4) {
        verifyPin(newPin);
      }
    }
  };

  const handleBackspace = () => {
    if (pin.length > 0) {
      setPin(pin.slice(0, -1));
      setError('');
    }
  };

  const handleClear = () => {
    setPin('');
    setError('');
  };

  const verifyPin = (submittedPin) => {
    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      // Hardcoded admin passcode is 1234 or admin
      if (submittedPin === '1234' || submittedPin === '8888') {
        mockLogin({ name: 'System Administrator', id: 'ADMIN-01', room: 'HQ-101', role: 'admin' });
        onNavigate('admin-dashboard');
      } else {
        setPin('');
        setError('Invalid administrator PIN key');
      }
    }, 800);
  };

  const pinDots = Array.from({ length: 4 }).map((_, i) => i < pin.length);

  return (
    <div className="flex-1 flex flex-col justify-between bg-gradient-to-b from-gray-900 to-gray-950 text-white p-6 relative overflow-hidden select-none">
      {/* Glow Blur Blobs */}
      <div className="absolute top-[-50px] right-[-50px] w-48 h-48 bg-primary/20 rounded-full blur-3xl pointer-events-none"></div>

      {/* Header back row */}
      <div className="flex items-center gap-3 mt-4 z-10">
        <button
          onClick={() => onNavigate('login')}
          className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-all border border-white/5"
        >
          <ArrowLeft size={18} />
        </button>
        <span className="text-xs font-bold uppercase tracking-wider text-gray-400">Exit Admin Mode</span>
      </div>

      {/* Main Lock Panel */}
      <div className="text-center z-10 flex-grow flex flex-col justify-center py-6">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-primary/20 text-primary border border-primary/20 mb-4 shadow-xl shadow-primary/10">
          <ShieldCheck size={26} className="animate-pulse" />
        </div>
        <h3 className="text-lg font-black tracking-tight">Admin Authentication</h3>
        <p className="text-xs text-gray-400 mt-1">Enter passcode to access metrics</p>

        {/* PIN Indicators */}
        <div className="flex justify-center gap-4.5 my-8">
          {pinDots.map((filled, idx) => (
            <div
              key={idx}
              className={`w-4 h-4 rounded-full border-2 transition-all duration-200 ${
                filled
                  ? 'bg-primary border-primary scale-110 shadow-lg shadow-primary/20'
                  : 'bg-transparent border-gray-600'
              }`}
            ></div>
          ))}
        </div>

        {error && (
          <div className="inline-flex items-center gap-1.5 mx-auto px-3.5 py-1.5 bg-danger/10 text-danger border border-danger/20 rounded-xl text-[10px] font-bold">
            <ShieldAlert size={14} />
            <span>{error}</span>
          </div>
        )}
      </div>

      {/* Keypad Grid */}
      <div className="grid grid-cols-3 gap-y-4 gap-x-6 mx-auto w-full max-w-[280px] pb-6 z-10">
        {[1, 2, 3, 4, 5, 6, 7, 8, 9].map((num) => (
          <button
            key={num}
            type="button"
            onClick={() => handleKeyPress(num)}
            className="w-16 h-16 rounded-full bg-white/5 border border-white/5 flex items-center justify-center text-xl font-bold hover:bg-white/10 active:scale-95 transition-all mx-auto"
          >
            {num}
          </button>
        ))}

        {/* Clear Button */}
        <button
          type="button"
          onClick={handleClear}
          className="w-16 h-16 flex items-center justify-center text-xs font-bold text-gray-400 hover:text-white transition-colors mx-auto"
        >
          CLEAR
        </button>

        {/* Zero */}
        <button
          type="button"
          onClick={() => handleKeyPress(0)}
          className="w-16 h-16 rounded-full bg-white/5 border border-white/5 flex items-center justify-center text-xl font-bold hover:bg-white/10 active:scale-95 transition-all mx-auto"
        >
          0
        </button>

        {/* Backspace */}
        <button
          type="button"
          onClick={handleBackspace}
          className="w-16 h-16 flex items-center justify-center text-gray-400 hover:text-white transition-colors mx-auto"
        >
          <Delete size={20} />
        </button>
      </div>
      
      {/* Test code hint */}
      <div className="text-[10px] text-center text-gray-500 pb-2 z-10">
        Demo Hint: Enter passcode <span className="font-bold text-primary">1234</span>
      </div>
    </div>
  );
}

import React, { useState } from 'react';
import { LogIn, KeyRound, User, Eye, EyeOff, ShieldAlert } from 'lucide-react';

export default function LoginScreen({ onNavigate, mockLogin }) {
  const [studentId, setStudentId] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!studentId || !password) {
      setError('Please fill in all fields');
      return;
    }
    setError('');
    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      // Determine if logging in as admin or student
      if (studentId === 'admin' || studentId.toLowerCase().includes('admin')) {
        onNavigate('admin-passcode');
      } else {
        mockLogin({ name: 'Zinat Zahan', id: studentId, room: '402-B', role: 'student' });
        onNavigate('home');
      }
    }, 800);
  };

  return (
    <div className="flex-1 flex flex-col justify-between bg-gradient-to-b from-primary/10 via-background-soft to-background-soft p-6 relative overflow-hidden select-none">
      {/* Decorative Blur Blobs */}
      <div className="absolute top-[-50px] right-[-50px] w-48 h-48 bg-primary/20 rounded-full blur-3xl pointer-events-none"></div>
      <div className="absolute bottom-12 left-[-60px] w-48 h-48 bg-accent/10 rounded-full blur-3xl pointer-events-none"></div>

      {/* Top Section */}
      <div className="mt-8 text-center z-10">
        <div className="inline-flex items-center justify-center w-16 h-16 rounded-3xl bg-primary text-white shadow-xl shadow-primary/30 mb-4 animate-bounce-slow">
          <LogIn size={28} />
        </div>
        <h1 className="text-3xl font-extrabold text-text-primary tracking-tight">Hall Meals</h1>
        <p className="text-text-secondary text-sm font-medium mt-1">Smart Meal Management Portal</p>
      </div>

      {/* Card Form */}
      <form onSubmit={handleSubmit} className="bg-white rounded-3xl p-6 shadow-xl shadow-primary/5 border border-primary/5 space-y-4 z-10">
        <h2 className="text-xl font-bold text-text-primary mb-2 text-left">Welcome Back</h2>

        {error && (
          <div className="flex items-center gap-2 p-3 text-xs bg-danger/10 text-danger border border-danger/20 rounded-xl">
            <ShieldAlert size={16} />
            <span>{error}</span>
          </div>
        )}

        {/* Student ID */}
        <div className="space-y-1">
          <label className="text-xs font-semibold text-text-secondary block text-left">Student ID / Username</label>
          <div className="relative">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-text-secondary">
              <User size={18} />
            </span>
            <input
              type="text"
              value={studentId}
              onChange={(e) => setStudentId(e.target.value)}
              placeholder="e.g. 20210804"
              className="w-full pl-10 pr-4 py-3 bg-background-soft border border-primary/10 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
            />
          </div>
        </div>

        {/* Passcode / PIN */}
        <div className="space-y-1">
          <label className="text-xs font-semibold text-text-secondary block text-left">Secret PIN / Password</label>
          <div className="relative">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-text-secondary">
              <KeyRound size={18} />
            </span>
            <input
              type={showPassword ? 'text' : 'password'}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              className="w-full pl-10 pr-10 py-3 bg-background-soft border border-primary/10 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute inset-y-0 right-0 pr-3 flex items-center text-text-secondary hover:text-primary transition-colors"
            >
              {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
            </button>
          </div>
        </div>

        {/* Forgot Password Link */}
        <div className="text-right">
          <a href="#forgot" className="text-xs font-semibold text-primary hover:text-primary-dark hover:underline">
            Forgot Passcode?
          </a>
        </div>

        {/* Submit Button */}
        <button
          type="submit"
          disabled={isLoading}
          className={`w-full py-3.5 rounded-2xl bg-primary text-white font-bold text-sm shadow-lg shadow-primary/20 hover:bg-primary-dark transition-all transform active:scale-98 flex items-center justify-center gap-2 ${
            isLoading ? 'opacity-85 cursor-not-allowed' : ''
          }`}
        >
          {isLoading ? (
            <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
          ) : (
            <>
              <span>Sign In</span>
              <LogIn size={16} />
            </>
          )}
        </button>
      </form>

      {/* Bottom Section / Navigation Links */}
      <div className="mt-4 text-center space-y-3 z-10 pb-6">
        <p className="text-xs text-text-secondary font-medium">
          New student?{' '}
          <button
            type="button"
            onClick={() => onNavigate('signup')}
            className="text-primary font-bold hover:underline"
          >
            Create Account
          </button>
        </p>
        
        <div className="inline-block">
          <button
            type="button"
            onClick={() => onNavigate('admin-passcode')}
            className="flex items-center justify-center gap-1.5 px-3 py-1.5 rounded-xl bg-accent-light/30 border border-accent/20 text-accent-dark text-xs font-bold hover:bg-accent-light/50 transition-all"
          >
            <ShieldAlert size={14} />
            <span>Admin Console</span>
          </button>
        </div>
      </div>
    </div>
  );
}

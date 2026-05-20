import React, { useState } from 'react';
import { UserPlus, User, Mail, Home, Hash, KeyRound, Eye, EyeOff, ShieldAlert, ArrowLeft } from 'lucide-react';

export default function SignupScreen({ onNavigate, mockLogin }) {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    room: '',
    studentId: '',
    password: '',
    confirmPassword: ''
  });
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const { name, email, room, studentId, password, confirmPassword } = formData;

    if (!name || !email || !room || !studentId || !password || !confirmPassword) {
      setError('Please fill in all registration fields');
      return;
    }

    if (password !== confirmPassword) {
      setError('Passcodes do not match');
      return;
    }

    setError('');
    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      mockLogin({ name, id: studentId, room, role: 'student' });
      onNavigate('home');
    }, 800);
  };

  return (
    <div className="flex-1 flex flex-col justify-between bg-gradient-to-b from-primary/10 via-background-soft to-background-soft p-6 relative overflow-hidden select-none">
      {/* Decorative Blur Blobs */}
      <div className="absolute top-[-50px] left-[-50px] w-48 h-48 bg-primary/20 rounded-full blur-3xl pointer-events-none"></div>

      {/* Top Header Row */}
      <div className="flex items-center gap-3 mt-4 z-10">
        <button
          onClick={() => onNavigate('login')}
          className="w-10 h-10 rounded-full bg-white flex items-center justify-center text-text-primary shadow-md hover:bg-background-soft transition-all"
        >
          <ArrowLeft size={18} />
        </button>
        <div>
          <h2 className="text-xl font-bold text-text-primary">Create Account</h2>
          <p className="text-xs text-text-secondary">Register your details to schedule meals</p>
        </div>
      </div>

      {/* Scrollable Form Area */}
      <form
        onSubmit={handleSubmit}
        className="flex-1 overflow-y-auto no-scrollbar my-4 bg-white rounded-3xl p-5 shadow-xl shadow-primary/5 border border-primary/5 space-y-3.5 z-10 max-h-[580px]"
      >
        {error && (
          <div className="flex items-center gap-2 p-3 text-xs bg-danger/10 text-danger border border-danger/20 rounded-xl">
            <ShieldAlert size={16} />
            <span>{error}</span>
          </div>
        )}

        {/* Full Name */}
        <div className="space-y-1">
          <label className="text-xs font-semibold text-text-secondary block text-left">Full Name</label>
          <div className="relative">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-text-secondary">
              <User size={16} />
            </span>
            <input
              type="text"
              name="name"
              value={formData.name}
              onChange={handleChange}
              placeholder="e.g. Zinat Zahan"
              className="w-full pl-9 pr-4 py-2.5 bg-background-soft border border-primary/10 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
            />
          </div>
        </div>

        {/* Email Address */}
        <div className="space-y-1">
          <label className="text-xs font-semibold text-text-secondary block text-left">Email Address</label>
          <div className="relative">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-text-secondary">
              <Mail size={16} />
            </span>
            <input
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              placeholder="e.g. zinat@univ.edu"
              className="w-full pl-9 pr-4 py-2.5 bg-background-soft border border-primary/10 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
            />
          </div>
        </div>

        {/* Room & Student ID Grid */}
        <div className="grid grid-cols-2 gap-3">
          <div className="space-y-1">
            <label className="text-xs font-semibold text-text-secondary block text-left">Room Number</label>
            <div className="relative">
              <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-text-secondary">
                <Home size={16} />
              </span>
              <input
                type="text"
                name="room"
                value={formData.room}
                onChange={handleChange}
                placeholder="402-B"
                className="w-full pl-9 pr-4 py-2.5 bg-background-soft border border-primary/10 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
              />
            </div>
          </div>
          <div className="space-y-1">
            <label className="text-xs font-semibold text-text-secondary block text-left">Student ID</label>
            <div className="relative">
              <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-text-secondary">
                <Hash size={16} />
              </span>
              <input
                type="text"
                name="studentId"
                value={formData.studentId}
                onChange={handleChange}
                placeholder="20210804"
                className="w-full pl-9 pr-4 py-2.5 bg-background-soft border border-primary/10 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
              />
            </div>
          </div>
        </div>

        {/* Password */}
        <div className="space-y-1">
          <label className="text-xs font-semibold text-text-secondary block text-left">Create Passcode PIN</label>
          <div className="relative">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-text-secondary">
              <KeyRound size={16} />
            </span>
            <input
              type={showPassword ? 'text' : 'password'}
              name="password"
              value={formData.password}
              onChange={handleChange}
              placeholder="••••••••"
              className="w-full pl-9 pr-9 py-2.5 bg-background-soft border border-primary/10 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute inset-y-0 right-0 pr-3 flex items-center text-text-secondary hover:text-primary transition-colors"
            >
              {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
            </button>
          </div>
        </div>

        {/* Confirm Password */}
        <div className="space-y-1">
          <label className="text-xs font-semibold text-text-secondary block text-left">Confirm Passcode PIN</label>
          <div className="relative">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-text-secondary">
              <KeyRound size={16} />
            </span>
            <input
              type={showPassword ? 'text' : 'password'}
              name="confirmPassword"
              value={formData.confirmPassword}
              onChange={handleChange}
              placeholder="••••••••"
              className="w-full pl-9 pr-9 py-2.5 bg-background-soft border border-primary/10 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
            />
          </div>
        </div>

        {/* Submit Button */}
        <button
          type="submit"
          disabled={isLoading}
          className={`w-full mt-3 py-3 rounded-2xl bg-primary text-white font-bold text-xs shadow-lg shadow-primary/20 hover:bg-primary-dark transition-all transform active:scale-98 flex items-center justify-center gap-2 ${
            isLoading ? 'opacity-85 cursor-not-allowed' : ''
          }`}
        >
          {isLoading ? (
            <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
          ) : (
            <>
              <span>Register Account</span>
              <UserPlus size={15} />
            </>
          )}
        </button>
      </form>

      {/* Bottom Footer Info */}
      <div className="text-center z-10 pb-4">
        <p className="text-xs text-text-secondary font-medium">
          Already registered?{' '}
          <button
            type="button"
            onClick={() => onNavigate('login')}
            className="text-primary font-bold hover:underline"
          >
            Sign In Here
          </button>
        </p>
      </div>
    </div>
  );
}

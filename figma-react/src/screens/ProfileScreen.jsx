import React, { useState } from 'react';
import { UserRound, Bell, Moon, Lock, LogOut, X, Shield, ShieldCheck } from 'lucide-react';
import BottomNavBar from '../components/BottomNavBar';

export default function ProfileScreen({ onNavigate, user, onLogout }) {
  const [notifications, setNotifications] = useState(true);
  const [darkMode, setDarkMode] = useState(false);
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [passwords, setPasswords] = useState({ old: '', newPassword: '', confirm: '' });
  const [passwordStatus, setPasswordStatus] = useState('');

  const handlePasswordSubmit = (e) => {
    e.preventDefault();
    if (!passwords.old || !passwords.newPassword || !passwords.confirm) {
      setPasswordStatus('Please fill in all fields');
      return;
    }
    if (passwords.newPassword !== passwords.confirm) {
      setPasswordStatus('New passcodes do not match');
      return;
    }
    setPasswordStatus('success');
    setTimeout(() => {
      setShowPasswordModal(false);
      setPasswordStatus('');
      setPasswords({ old: '', newPassword: '', confirm: '' });
    }, 1200);
  };

  return (
    <div className="flex-1 flex flex-col justify-between bg-background-soft select-none overflow-hidden relative">
      {/* Header */}
      <div className="bg-white px-5 pt-6 pb-4 border-b border-gray-100 z-10">
        <div className="flex justify-between items-center mt-4">
          <div className="text-left">
            <h2 className="text-xl font-bold text-text-primary">Profile</h2>
            <p className="text-xs text-text-secondary">Manage settings & security</p>
          </div>
          <div className="w-10 h-10 rounded-2xl bg-primary/10 flex items-center justify-center text-primary">
            <UserRound size={20} />
          </div>
        </div>
      </div>

      {/* Main Settings List */}
      <div className="flex-grow overflow-y-auto no-scrollbar px-5 py-4 space-y-4">
        {/* Profile Card Summary */}
        <div className="bg-white rounded-3xl p-5 shadow-sm border border-primary/5 text-center flex flex-col items-center">
          <div className="w-16 h-16 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center text-primary font-black text-2xl mb-3 shadow-inner">
            {user.name ? user.name.charAt(0) : 'S'}
          </div>
          <h3 className="font-extrabold text-base text-text-primary">{user.name || 'Zinat Zahan'}</h3>
          <p className="text-xs text-text-secondary mt-0.5">{user.email || 'zinat@univ.edu'}</p>

          <div className="grid grid-cols-2 gap-4 w-full bg-background-soft p-3.5 rounded-2xl border border-primary/5 mt-4 text-xs font-semibold">
            <div className="text-left border-r border-gray-200/50">
              <p className="text-[9px] text-text-secondary uppercase">Room</p>
              <p className="font-bold text-text-primary mt-0.5">{user.room || '402-B'}</p>
            </div>
            <div className="text-left pl-2">
              <p className="text-[9px] text-text-secondary uppercase">Student ID</p>
              <p className="font-bold text-text-primary mt-0.5">{user.id || '20210804'}</p>
            </div>
          </div>
        </div>

        {/* General Toggles */}
        <div className="bg-white rounded-3xl p-4 shadow-sm border border-primary/5 space-y-3.5 text-left">
          <h4 className="text-[10px] font-extrabold text-text-secondary uppercase px-1 tracking-wider">Preferences</h4>
          
          {/* Notifications Switch */}
          <div className="flex justify-between items-center py-0.5 px-1">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-xl bg-primary/10 flex items-center justify-center text-primary">
                <Bell size={16} />
              </div>
              <span className="text-xs font-bold text-text-primary">Meal Alerts & Reminders</span>
            </div>
            <button
              onClick={() => setNotifications(!notifications)}
              className={`w-11 h-6.5 rounded-full p-0.5 transition-colors ${notifications ? 'bg-primary' : 'bg-gray-300'}`}
            >
              <div className={`w-5 h-5 rounded-full bg-white shadow transform transition-transform ${notifications ? 'translate-x-4.5' : 'translate-x-0'}`}></div>
            </button>
          </div>

          {/* Dark Mode Switch */}
          <div className="flex justify-between items-center py-0.5 px-1">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-xl bg-accent/15 flex items-center justify-center text-accent-dark">
                <Moon size={16} />
              </div>
              <span className="text-xs font-bold text-text-primary">Dark Mode Theme</span>
            </div>
            <button
              onClick={() => setDarkMode(!darkMode)}
              className={`w-11 h-6.5 rounded-full p-0.5 transition-colors ${darkMode ? 'bg-primary' : 'bg-gray-300'}`}
            >
              <div className={`w-5 h-5 rounded-full bg-white shadow transform transition-transform ${darkMode ? 'translate-x-4.5' : 'translate-x-0'}`}></div>
            </button>
          </div>
        </div>

        {/* Security & Action Buttons */}
        <div className="bg-white rounded-3xl p-4 shadow-sm border border-primary/5 space-y-3 text-left">
          <h4 className="text-[10px] font-extrabold text-text-secondary uppercase px-1 tracking-wider">Security</h4>

          {/* Change Password Trigger */}
          <button
            onClick={() => setShowPasswordModal(true)}
            className="w-full flex items-center gap-3 py-2 px-1 hover:bg-background-soft rounded-xl transition-all"
          >
            <div className="w-8 h-8 rounded-xl bg-primary/10 flex items-center justify-center text-primary">
              <Lock size={15} />
            </div>
            <div className="text-left flex-grow">
              <p className="text-xs font-bold text-text-primary">Change PIN / Passcode</p>
              <p className="text-[9px] text-text-secondary mt-0.5">Keep your authorization key secure</p>
            </div>
          </button>

          {/* Logout Button */}
          <button
            onClick={() => {
              onLogout();
              onNavigate('login');
            }}
            className="w-full flex items-center gap-3 py-2 px-1 text-danger hover:bg-danger/5 rounded-xl transition-all"
          >
            <div className="w-8 h-8 rounded-xl bg-danger/10 flex items-center justify-center text-danger">
              <LogOut size={15} />
            </div>
            <div className="text-left">
              <p className="text-xs font-bold">Sign Out Account</p>
              <p className="text-[9px] text-danger/70 mt-0.5">Disconnect from the management portal</p>
            </div>
          </button>
        </div>
      </div>

      {/* Change Password Dialog Overlay */}
      {showPasswordModal && (
        <div className="absolute inset-0 bg-black/60 backdrop-blur-xs z-50 flex items-end animate-fade-in">
          <div className="w-full bg-white rounded-t-[32px] p-6 shadow-2xl border-t border-primary/15 animate-slide-up space-y-4">
            <div className="flex justify-between items-center">
              <div className="flex items-center gap-2">
                <Lock size={18} className="text-primary" />
                <h4 className="font-extrabold text-sm text-text-primary">Change Passcode PIN</h4>
              </div>
              <button
                onClick={() => {
                  setShowPasswordModal(false);
                  setPasswordStatus('');
                }}
                className="w-8 h-8 rounded-full bg-background-soft flex items-center justify-center text-text-secondary hover:bg-gray-200"
              >
                <X size={15} />
              </button>
            </div>

            {passwordStatus === 'success' ? (
              <div className="p-5 text-center space-y-3">
                <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-primary/15 text-primary">
                  <ShieldCheck size={26} />
                </div>
                <h5 className="font-bold text-xs text-text-primary">PIN Updated Successfully!</h5>
              </div>
            ) : (
              <form onSubmit={handlePasswordSubmit} className="space-y-3.5 text-left">
                {passwordStatus && (
                  <div className="p-3 text-[11px] bg-danger/10 text-danger border border-danger/20 rounded-xl flex items-center gap-1.5 font-bold">
                    <Shield size={14} />
                    <span>{passwordStatus}</span>
                  </div>
                )}

                {/* Old password */}
                <div className="space-y-1">
                  <label className="text-[10px] font-bold text-text-secondary">Current PIN</label>
                  <input
                    type="password"
                    value={passwords.old}
                    onChange={(e) => setPasswords({ ...passwords, old: e.target.value })}
                    placeholder="••••••••"
                    className="w-full px-3 py-2 bg-background-soft border border-primary/10 rounded-xl text-xs focus:outline-none focus:ring-1 focus:ring-primary"
                  />
                </div>

                {/* New password */}
                <div className="space-y-1">
                  <label className="text-[10px] font-bold text-text-secondary">New PIN</label>
                  <input
                    type="password"
                    value={passwords.newPassword}
                    onChange={(e) => setPasswords({ ...passwords, newPassword: e.target.value })}
                    placeholder="••••••••"
                    className="w-full px-3 py-2 bg-background-soft border border-primary/10 rounded-xl text-xs focus:outline-none focus:ring-1 focus:ring-primary"
                  />
                </div>

                {/* Confirm new password */}
                <div className="space-y-1">
                  <label className="text-[10px] font-bold text-text-secondary">Confirm New PIN</label>
                  <input
                    type="password"
                    value={passwords.confirm}
                    onChange={(e) => setPasswords({ ...passwords, confirm: e.target.value })}
                    placeholder="••••••••"
                    className="w-full px-3 py-2 bg-background-soft border border-primary/10 rounded-xl text-xs focus:outline-none focus:ring-1 focus:ring-primary"
                  />
                </div>

                <button
                  type="submit"
                  className="w-full mt-2 py-3 rounded-2xl bg-primary text-white font-extrabold text-xs shadow-md shadow-primary/15 hover:bg-primary-dark"
                >
                  Save Passcode
                </button>
              </form>
            )}
          </div>
        </div>
      )}

      {/* Nav */}
      <BottomNavBar activeTab="profile" onNavigate={onNavigate} />
    </div>
  );
}

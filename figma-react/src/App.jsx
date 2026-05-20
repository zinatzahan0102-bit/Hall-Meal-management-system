import React, { useState } from 'react';
import { Wifi, Battery, Signal, Layers, FileCode, CheckCircle, ExternalLink } from 'lucide-react';

// Import Screens
import LoginScreen from './screens/LoginScreen';
import SignupScreen from './screens/SignupScreen';
import StudentHomeScreen from './screens/StudentHomeScreen';
import MealsCalendarScreen from './screens/MealsCalendarScreen';
import DailyMenuScreen from './screens/DailyMenuScreen';
import ActivityScreen from './screens/ActivityScreen';
import ComplaintBoxScreen from './screens/ComplaintBoxScreen';
import ProfileScreen from './screens/ProfileScreen';
import AdminPasscodeScreen from './screens/AdminPasscodeScreen';
import AdminDashboardScreen from './screens/AdminDashboardScreen';

export default function App() {
  const [activeScreen, setActiveScreen] = useState('login');
  const [user, setUser] = useState({
    name: 'Zinat Zahan',
    id: '20210804',
    room: '402-B',
    email: 'zinat@univ.edu',
    role: 'student'
  });

  const handleNavigate = (screenId) => {
    setActiveScreen(screenId);
  };

  const handleMockLogin = (userData) => {
    setUser({
      ...user,
      ...userData,
      email: userData.role === 'admin' ? 'admin@univ.edu' : `${userData.name.toLowerCase().replace(' ', '')}@univ.edu`
    });
  };

  const handleLogout = () => {
    setUser({
      name: '',
      id: '',
      room: '',
      email: '',
      role: ''
    });
  };

  // List of screens for the side menu controller
  const screensList = [
    { id: 'login', title: '1. Login Screen', category: 'Authentication', file: 'LoginScreen.jsx' },
    { id: 'signup', title: '2. Signup Screen', category: 'Authentication', file: 'SignupScreen.jsx' },
    { id: 'home', title: '3. Student Home', category: 'Student Flow', file: 'StudentHomeScreen.jsx' },
    { id: 'meals', title: '4. Meals Calendar', category: 'Student Flow', file: 'MealsCalendarScreen.jsx' },
    { id: 'menu', title: '5. Daily Menu', category: 'Student Flow', file: 'DailyMenuScreen.jsx' },
    { id: 'activity', title: '6. Activity & Logs', category: 'Student Flow', file: 'ActivityScreen.jsx' },
    { id: 'complaint', title: '7. File Complaint', category: 'Student Flow', file: 'ComplaintBoxScreen.jsx' },
    { id: 'profile', title: '8. Profile & Settings', category: 'Student Flow', file: 'ProfileScreen.jsx' },
    { id: 'admin-passcode', title: '9. Admin PIN Gate', category: 'Admin Flow', file: 'AdminPasscodeScreen.jsx' },
    { id: 'admin-dashboard', title: '10. Admin Dashboard', category: 'Admin Flow', file: 'AdminDashboardScreen.jsx' },
  ];

  // Screen descriptions
  const screenDescriptions = {
    'login': 'Gradient entry portal featuring custom passcode logic, verification alerts, and quick actions to admin bypass gates.',
    'signup': 'Student registration panel for name, room assignment, student ID, and secure PIN parameters.',
    'home': 'Main dashboard dashboard featuring next-day meal toggles, 2x2 statistics panels, and active meal counts.',
    'meals': 'Interactive calendar calendar layout supporting single day selections and multi-day status actions.',
    'menu': 'Weekly menus displaying breakfast, lunch, and dinner options with custom pricing.',
    'activity': 'Three-tab log containing meal consumption checkmarks, star reviews, and logged complaints.',
    'complaint': 'Student feedback form with drop-down categories, text areas, and photo selection controls.',
    'profile': 'Account settings hub including preference toggles, notification rules, and change passcode dialogue overlays.',
    'admin-passcode': 'Security pad screen verifying system credentials using a custom touch keypad layout.',
    'admin-dashboard': 'Five-tab manager supporting student directories, menu rate edits, chat communications, complaint replies, and global rules.'
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0d0f0e] via-[#151917] to-[#0c0e0d] flex items-center justify-center p-4 md:p-8 font-sans">
      <div className="w-full max-w-6xl bg-gray-900/30 border border-white/5 rounded-[40px] p-6 md:p-10 backdrop-blur-xl flex flex-col md:flex-row gap-8 items-center md:items-start justify-center shadow-2xl">
        
        {/* Left Hand: Controller & Details panel */}
        <div className="flex-1 w-full flex flex-col gap-6 text-left">
          <div>
            <span className="text-[10px] bg-primary/20 text-primary border border-primary/20 font-black px-3 py-1 rounded-full uppercase tracking-wider">
              Figma UI React Code Sandbox
            </span>
            <h1 className="text-3xl md:text-4xl font-extrabold text-white tracking-tight mt-3">
              Hall Meal Management System
            </h1>
            <p className="text-gray-400 text-sm mt-1.5 leading-relaxed">
              Fully interactive React + Tailwind CSS mobile UI code. Each screen is modular and copy-pasteable directly to support design-to-code pipelines.
            </p>
          </div>

          {/* Screen Selection Grid */}
          <div className="space-y-4">
            <h3 className="text-xs font-black uppercase text-gray-500 tracking-wider flex items-center gap-1.5">
              <Layers size={14} />
              <span>Select Mockup Screen</span>
            </h3>
            
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
              {screensList.map((screen) => (
                <button
                  key={screen.id}
                  onClick={() => handleNavigate(screen.id)}
                  className={`p-3 rounded-2xl border text-left transition-all ${
                    activeScreen === screen.id
                      ? 'bg-primary border-primary text-white shadow-lg shadow-primary/10 scale-102 font-bold'
                      : 'bg-white/5 border-white/5 text-gray-300 hover:bg-white/10 hover:border-white/10'
                  }`}
                >
                  <div className="flex justify-between items-start gap-1">
                    <div>
                      <p className="text-xs font-bold">{screen.title}</p>
                      <p className={`text-[9px] mt-0.5 ${activeScreen === screen.id ? 'text-white/80' : 'text-gray-400'}`}>
                        {screen.category}
                      </p>
                    </div>
                    {activeScreen === screen.id && (
                      <CheckCircle size={14} className="stroke-[2.5] shrink-0" />
                    )}
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Screen Specific Code Reference */}
          <div className="bg-white/5 border border-white/5 p-5 rounded-3xl space-y-2">
            <div className="flex justify-between items-center">
              <h4 className="text-xs font-black text-gray-400 uppercase tracking-wider flex items-center gap-1.5">
                <FileCode size={14} className="text-primary" />
                <span>React Component File</span>
              </h4>
              <span className="text-[10px] font-mono text-primary bg-primary/10 border border-primary/20 px-2 py-0.5 rounded-md font-bold">
                {screensList.find(s => s.id === activeScreen)?.file}
              </span>
            </div>
            <p className="text-xs text-gray-300 leading-relaxed mt-1">
              {screenDescriptions[activeScreen]}
            </p>
            <div className="text-[10px] text-gray-500 mt-2 italic flex items-center gap-1">
              <ExternalLink size={10} />
              <span>Location: src/screens/{screensList.find(s => s.id === activeScreen)?.file}</span>
            </div>
          </div>
        </div>

        {/* Right Hand: iPhone Device Frame Simulator */}
        <div className="shrink-0 flex items-center justify-center relative">
          <div className="mobile-frame">
            {/* Speaker Notches */}
            <div className="mobile-frame-notch"></div>
            
            {/* Status Bar */}
            <div className={`mobile-status-bar ${activeScreen === 'admin-passcode' ? 'text-white' : 'text-text-primary'}`}>
              <span>9:41</span>
              <div className="flex items-center gap-1.5">
                <Signal size={13} className="stroke-[2.5]" />
                <Wifi size={13} className="stroke-[2.5]" />
                <Battery size={13} className="stroke-[2.5]" />
              </div>
            </div>

            {/* Screen Content Body Wrapper */}
            <div className="flex-1 flex flex-col overflow-hidden relative">
              {activeScreen === 'login' && (
                <LoginScreen onNavigate={handleNavigate} mockLogin={handleMockLogin} />
              )}
              {activeScreen === 'signup' && (
                <SignupScreen onNavigate={handleNavigate} mockLogin={handleMockLogin} />
              )}
              {activeScreen === 'home' && (
                <StudentHomeScreen onNavigate={handleNavigate} user={user} />
              )}
              {activeScreen === 'meals' && (
                <MealsCalendarScreen onNavigate={handleNavigate} />
              )}
              {activeScreen === 'menu' && (
                <DailyMenuScreen onNavigate={handleNavigate} />
              )}
              {activeScreen === 'activity' && (
                <ActivityScreen onNavigate={handleNavigate} />
              )}
              {activeScreen === 'complaint' && (
                <ComplaintBoxScreen onNavigate={handleNavigate} />
              )}
              {activeScreen === 'profile' && (
                <ProfileScreen onNavigate={handleNavigate} user={user} onLogout={handleLogout} />
              )}
              {activeScreen === 'admin-passcode' && (
                <AdminPasscodeScreen onNavigate={handleNavigate} mockLogin={handleMockLogin} />
              )}
              {activeScreen === 'admin-dashboard' && (
                <AdminDashboardScreen onNavigate={handleNavigate} user={user} onLogout={handleLogout} />
              )}
            </div>

            {/* Home indicator bar (iPhone style) */}
            <div className="mobile-home-indicator"></div>
          </div>
        </div>

      </div>
    </div>
  );
}

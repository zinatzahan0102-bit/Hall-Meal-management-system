import React, { useState } from 'react';
import { ArrowLeft, Send, CheckCircle2, ShieldAlert, Image as ImageIcon, Trash2 } from 'lucide-react';
import BottomNavBar from '../components/BottomNavBar';

export default function ComplaintBoxScreen({ onNavigate }) {
  const [category, setCategory] = useState('Food Quality');
  const [description, setDescription] = useState('');
  const [mockPhoto, setMockPhoto] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [error, setError] = useState('');

  const categories = ['Food Quality', 'Service', 'Suggestions', 'Cleanliness', 'Others'];

  const handlePhotoUpload = () => {
    // Simulate image uploading
    setMockPhoto({
      name: 'meal_issue.jpg',
      url: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3'
    });
  };

  const handleRemovePhoto = () => {
    setMockPhoto(null);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!description.trim()) {
      setError('Please describe your concern or feedback');
      return;
    }
    setError('');
    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
      setIsSuccess(true);
    }, 1000);
  };

  return (
    <div className="flex-1 flex flex-col justify-between bg-background-soft select-none overflow-hidden relative">
      {/* Top Header */}
      <div className="bg-white px-5 pt-6 pb-4 border-b border-gray-100 flex items-center gap-3 z-10">
        <button
          onClick={() => onNavigate('activity')}
          className="w-9 h-9 mt-4 rounded-full bg-background-soft flex items-center justify-center text-text-primary hover:bg-gray-200 transition-all"
        >
          <ArrowLeft size={16} />
        </button>
        <div className="text-left mt-4">
          <h2 className="text-xl font-bold text-text-primary">File Complaint</h2>
          <p className="text-xs text-text-secondary">Send feedback directly to admins</p>
        </div>
      </div>

      {/* Main Content Form */}
      <div className="flex-1 overflow-y-auto no-scrollbar px-5 py-4">
        {isSuccess ? (
          <div className="bg-white rounded-3xl p-6 shadow-sm border border-primary/5 text-center my-6 space-y-4 animate-fade-in">
            <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-primary/10 text-primary mb-2">
              <CheckCircle2 size={36} className="stroke-[2.5]" />
            </div>
            <h4 className="font-extrabold text-lg text-text-primary">Report Submitted</h4>
            <p className="text-xs text-text-secondary leading-relaxed">
              Your concern was logged under ID <span className="font-bold text-text-primary">CMP-204</span>. Admins will review and reply shortly.
            </p>
            <button
              onClick={() => {
                setIsSuccess(false);
                setDescription('');
                setMockPhoto(null);
                onNavigate('activity');
              }}
              className="w-full py-3 rounded-2xl bg-primary text-white font-bold text-xs hover:bg-primary-dark shadow-md"
            >
              Back to Activity Logs
            </button>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="bg-white rounded-3xl p-5 shadow-sm border border-primary/5 space-y-4 text-left">
            {error && (
              <div className="flex items-center gap-2 p-3 text-xs bg-danger/10 text-danger border border-danger/20 rounded-xl">
                <ShieldAlert size={16} />
                <span>{error}</span>
              </div>
            )}

            {/* Category selection */}
            <div className="space-y-1">
              <label className="text-xs font-semibold text-text-secondary block">Select Issue Category</label>
              <div className="grid grid-cols-2 gap-2">
                {categories.map((cat) => (
                  <button
                    key={cat}
                    type="button"
                    onClick={() => setCategory(cat)}
                    className={`py-2 px-3 rounded-xl border text-[11px] font-bold text-center transition-all ${
                      category === cat
                        ? 'bg-primary/10 border-primary text-primary'
                        : 'bg-background-soft border-primary/5 text-text-secondary hover:bg-gray-100'
                    }`}
                  >
                    {cat}
                  </button>
                ))}
              </div>
            </div>

            {/* Description textarea */}
            <div className="space-y-1 mt-2">
              <label className="text-xs font-semibold text-text-secondary block">Describe the Issue</label>
              <textarea
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                rows="4"
                placeholder="Please explain the problem clearly. Mention date, meal type, or detail if relevant..."
                className="w-full p-3.5 bg-background-soft border border-primary/10 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all placeholder:text-text-secondary/60 resize-none"
              ></textarea>
            </div>

            {/* Attachment preview / select */}
            <div className="space-y-1">
              <label className="text-xs font-semibold text-text-secondary block">Add Photo Reference (Optional)</label>
              
              {mockPhoto ? (
                <div className="relative rounded-2xl overflow-hidden border border-primary/10 aspect-video bg-background-soft">
                  <img
                    src={mockPhoto.url}
                    alt="attachment"
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute inset-0 bg-black/35 flex items-center justify-center gap-2">
                    <button
                      type="button"
                      onClick={handleRemovePhoto}
                      className="w-8 h-8 rounded-full bg-danger text-white flex items-center justify-center hover:bg-danger-dark transition-all"
                    >
                      <Trash2 size={14} />
                    </button>
                  </div>
                </div>
              ) : (
                <button
                  type="button"
                  onClick={handlePhotoUpload}
                  className="w-full py-4 border-2 border-dashed border-primary/15 hover:border-primary/30 rounded-2xl flex flex-col items-center justify-center text-text-secondary hover:text-primary transition-all bg-background-soft/50"
                >
                  <ImageIcon size={22} className="opacity-70 mb-1" />
                  <span className="text-[10px] font-bold">Attach Photo (Tap to simulate)</span>
                </button>
              )}
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isLoading}
              className={`w-full py-3.5 rounded-2xl bg-primary text-white font-extrabold text-xs shadow-lg shadow-primary/20 hover:bg-primary-dark transition-all transform active:scale-98 flex items-center justify-center gap-1.5 ${
                isLoading ? 'opacity-85 cursor-not-allowed' : ''
              }`}
            >
              {isLoading ? (
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
              ) : (
                <>
                  <span>File Complaint</span>
                  <Send size={13} />
                </>
              )}
            </button>
          </form>
        )}
      </div>

      {/* Nav */}
      <BottomNavBar activeTab="activity" onNavigate={onNavigate} />
    </div>
  );
}
